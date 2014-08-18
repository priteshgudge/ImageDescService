require 'uri'
module EpubUtils
  def valid_epub_zip?(file)
    EpubUtils.valid_epub_zip?(file)
  end
  
  # checks for mimetype container file
  def self.valid_epub_zip?(file)
      Zip::Archive.open(file) do |zipfile|
        zipfile.each do |entry|
          if entry.name == "META-INF/container.xml"
            return true
          end
        end
      end
    return false
  end
  
  def get_epub_file_main_directory(book_directory)
       EpubUtils.get_epub_file_main_directory(book_directory)
  end
  
  def self.get_epub_file_main_directory(book_directory)
       opf_file = "**/package.opf" 
       opf_dir = Dir.glob("#{book_directory}/#{opf_file}").first
       File.dirname opf_dir
  end     
  
  def self.get_contents_xml_name(book_directory)
      book_dir = get_epub_file_main_directory book_directory
      return Dir.glob(File.join(book_dir, 'package.opf'))[0]
  end
  
  def self.get_epub_book_xml_file_names(book_directory)
     # Get opf
     doc = Nokogiri::XML get_xml_from_dir(book_directory, "Epub")
     
     # get main directory
     mainDirectory = EpubUtils.get_epub_file_main_directory(book_directory)
     
     #Use spine to get ordered list of content.
     filenames = Array.new
     doc.search('itemref').each do |itemref| 
       itemURI = URI(doc.xpath('//*[@id="' + itemref['idref'] + '"]').first['href'])
       filename = itemURI.scheme.nil? ? mainDirectory + "/" + itemURI.to_s : itemURI.to_s
       filenames.push(filename) 
     end
     
     return filenames
  end
   
  def self.extract_book_uid(doc)
    # determine the ID for unique-identifier
    uid_id = doc.xpath('/opf:package/@unique-identifier', {'opf' => 'http://www.idpf.org/2007/opf'}).first

    # look up the ID
    if uid_id != nil
      xpath_uid = doc.xpath('//*[@id="' + uid_id + '"]').first
    end

    if xpath_uid == nil || xpath_uid.text == nil
      raise MissingBookUIDException.new
    end

    # return sanitized version
    return xpath_uid.text.gsub(/[^a-zA-Z0-9\-\_]/, '-')
  end
  
  def self.extract_book_title(doc)
    titleElement = doc.xpath('//dc:title', {'dc' => 'http://purl.org/dc/elements/1.1/'}).first
    titleElement.text if titleElement
  end
  
  def extract_images_prod_notes_for_epub doc, book_directory
     @described_by_hash = Hash.new()
     @described_at_hash = Hash.new()
     @alt_text_hash = Hash.new()
     @longdesc_hash = Hash.new()
     limit = 249
     book_uid = EpubUtils.extract_book_uid doc
     book = Book.where(:uid => book_uid, :deleted_at => nil).first
     file_names = EpubUtils.get_epub_book_xml_file_names(book_directory)
     file_contents = file_names.inject('') do |acc, file_name|
      cur_file_contents = File.read(file_name)
      cur_doc = Nokogiri::XML cur_file_contents
      acc = "#{acc} #{cur_doc.css('body').children.to_s}"
      acc
     end
     mainDirectory = EpubUtils.get_epub_file_main_directory(book_directory)

     file_contents = "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en'><link rel='stylesheet' type='text/css' href='//s3.amazonaws.com/org-benetech-poet/html.css'/><body>#{file_contents}</body></html>"
     doc = Nokogiri::XML file_contents
     @num_images = doc.css('img').size()
     doc.css('img').each do |img_node| 
       unless (img_node['src']).blank? 
         image_name =  img_node['src'].gsub!(/images\//i, '') 
         alt_text =  img_node['alt']
         if alt_text.size > 1
           @alt_text_hash[image_name] = alt_text
         end
         break if @alt_text_hash.size > limit
         unless img_node['aria-describedby'].blank?
           describer = doc.css('#' + img_node['aria-describedby'])[0]
           @described_by_hash[image_name] = describer.text
         end
         unless img_node.parent().name() != "figure" && img_node.parent()['aria-describedby'].blank?
           describer = doc.css('#' + img_node.parent()['aria-describedby'])[0]
           @described_by_hash[image_name] = describer.text
         end

         unless img_node['aria-describedat'].blank?
           @described_at_hash[image_name] = img_node['aria-describedat']
         end
         unless img_node['longdesc'].blank?
           @longdesc_hash[image_name] = img_node['longdesc']
         end
       end
     end
  end
 
  #  def caller_info
  #    return "#{request.remote_addr}"
  #  end

end