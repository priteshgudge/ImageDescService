include UnzipUtils, EpubUtils

class EpubParser <  S3UnzippingJob

   def perform
      begin
        repository = RepositoryChooser.choose(repository_name)
        
        book = Book.where(:id => book_id, :deleted_at => nil).first
        file = repository.read_file(book.uid + ".zip", File.join( "", "tmp", "#{book.uid}.zip"))
        book_directory  = accept_book(file)
        xml = get_xml_from_dir(book_directory, book.file_type)
        doc = Nokogiri::XML xml

        file_names = EpubUtils.get_epub_book_xml_file_names(book_directory)
        file_contents = file_names.inject('') do |acc, file_name|
          cur_file_contents = File.read(file_name)
          cur_doc = Nokogiri::XML cur_file_contents
          acc = "#{acc} #{cur_doc.css('body').children.to_s}"
          acc
        end
        file_contents = "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en'><link rel='stylesheet' type='text/css' href='//s3.amazonaws.com/org-benetech-poet/html.css'/><body>#{file_contents}</body></html>"


        book = Book.where(:id => book_id, :deleted_at => nil).first
        book = update_epub_book_in_db(book, doc, file_names.join(', '), uploader_id)

        splitter = SplitXmlHelper::DTBookSplitter.new(IMAGE_LIMIT)
        parser = Nokogiri::XML::SAX::Parser.new(splitter)
        parser.parse(file_contents)

        # Keep track of the original img src attribute and whether it has been used already
        image_srces = []

        # in case this is a re-upload, we should reset the book_fragment_id of the images
        DynamicImage.update_all({:book_fragment_id => nil}, {:book_id => book.id})
        book.update_attribute("status", 2)
        
        splitter.segments.each_with_index do |segment_xml, i|
            sequence_number = i+1
            book_fragment = BookFragment.where(:book_id => book.id, :sequence_number => sequence_number).first || BookFragment.create(:book_id => book.id, :sequence_number => sequence_number)
            doc = Nokogiri::XML segment_xml
 
            create_images_in_database(book, book_fragment, book_directory, doc)
            doc.css('img').each do |img_node| 
              unless (img_node['src']).blank?
                db_image = DynamicImage.where(:book_id => book.id, :image_location => EpubUtils.sanitize_image_location(img_node['src'])).first
                if db_image
                  img_node['img-id'] = db_image.id.to_s
                  img_node['original'] = image_srces.include?(img_node['src']) ? '0' : '1' 
                end
                image_srces << img_node['src']
              end
            end
            segment_xml = doc.to_xml

            content_html = File.join("","tmp", "#{book.uid}_#{sequence_number}.html")
            File.open(content_html, 'wb'){|f|f.write(segment_xml)}
            repository.store_file(content_html, book.uid, "#{book.uid}/#{book.uid}_#{sequence_number}.html", nil)
        end
          
        book.update_attribute("status", 3) 
        doc = nil
        xml = nil
        current_user = User.where(:id => uploader_id, :deleted_at => nil).first
        UserMailer.book_uploaded_email(current_user, book).deliver #email 'current user'

        # remove zip file from holding bucket
        repository.remove_file(book.uid + ".zip")

        daisy_file = nil

        rescue Exception => e
            book.update_attribute("status", 5) if book
            puts "Unknown problem in unzipping job for book #{book.uid}"
            puts "#{e.class}: #{e.message}"
            puts e.backtrace.join("\n")
            $stderr.puts e
      end
    end

    def update_epub_book_in_db(book, doc, xml_file, uploader)
      @book_title = EpubUtils.extract_book_title(doc)
      @book_publisher = doc.css("[property='dcterms:publisher']").first.text if doc.css("[property='dcterms:publisher']").first
      @book_publisher_date = doc.css("[property='dc:date']").first.text if doc.css("[property='dc:date']").first
      description =  doc.css("[property='dcterms:description']").first.text if doc.css("[property='dcterms:description']").first
      author =  doc.css("[property='dcterms:creator']").first.text if doc.css("[property='dcterms:creator']").first
      isbn = extract_optional_epub_isbn(doc) 
      book.update_attributes(:title => @book_title, :isbn => isbn, :xml_file => xml_file, :status => 1, :publisher => @book_publisher, :publisher_date => @book_publisher_date, :description => description, :authors => author)    
      book
    end    
    
    #do we have isbn in these files?? ask
    def extract_optional_epub_isbn(doc)
      matches = doc.xpath("//dc:Identifier[@scheme='ISBN']", 'dc' => 'http://purl.org/dc/elements/1.1/')
      if matches.size != 1
        return nil
      end
      node = matches.first
      node.text
    end
  
    def each_image (doc)
      doc.css('img').each do | image_node |
        yield(image_node)
      end
    end

    def get_image_path(book_directory, image_location)
        get_epub_file_main_directory(book_directory) + "/" + EpubUtils.sanitize_image_location(image_location)
    end

end