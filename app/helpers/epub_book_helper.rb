module EpubBookHelper
  class BatchHelper
    ROOT_XPATH = "/xmlns:dtbook"
    NS_EPUB = "http://www.idpf.org/2007/ops"
    ASIDE_PREFIX = "poet_description_"

    def self.batch_add_descriptions_to_book job_id, current_library
      job = Job.where(:id => job_id).first
      # Retrieve file from S3
      repository = RepositoryChooser.choose
      enter_params = job.json_enter_params
      password = enter_params['password']
      random_uid = enter_params['random_uid']
      random_uid_book_location = repository.read_file(random_uid, File.join( "", "tmp", "#{random_uid}.zip"))
      zip_directory, book_directory, epub_file = UnzipUtils.accept_and_copy_book(random_uid_book_location, "Epub")
      book = File.open epub_file
      unless password.blank?
        begin
          Zip::Archive.decrypt(book.path, password)
        rescue Zip::Error => e
          Rails.logger.info "#{e.class}: #{e.message}"
          if e.message.include?("Wrong password")
            Rails.logger.info "Invalid Password for encrypted zip"
            flash[:alert] = "Please check your password and re-enter"
          else
            Rails.logger.info "Other problem with encrypted zip"
            flash[:alert] = "There is a problem with this zip file"
          end
          redirect_to :action => 'process'
          return
        end
      end

      if !EpubUtils.valid_epub_zip?(book.path)
        flash[:alert] = "Not a valid Epub book"
        redirect_to :action => 'process'
        return
      end
      
      begin
        get_epub_with_descriptions zip_directory, book_directory, epub_file, job, current_library
      rescue Zip::Error => e
        Rails.logger.info "#{e.class}: #{e.message}"
        if e.message.include?("File encrypted")
          Rails.logger.info "Password needed for zip"
          flash[:alert] = "Please enter a password for this book"
        else
          Rails.logger.info "Other problem with zip"
          flash[:alert] = "There is a problem with this zip file"
        end

        redirect_to :action => 'process'
        return
      end
    end
    
  
    def self.get_epub_with_descriptions zip_directory, book_directory, epub_file, job, current_library
      begin
        contents_filenames = EpubUtils.get_epub_book_xml_file_names(book_directory)
        content_documents = get_content_documents_with_updated_descriptions(book_directory, contents_filenames, current_library)
        zip_filename = create_zip(epub_file, content_documents)
        basename = File.basename(contents_filenames[0])
        Rails.logger.info "Sending zip #{zip_filename} of length #{File.size(zip_filename)}"
      
        # Store this file in S3, update the Job; change exit_params and the state
        random_uid = UUIDTools::UUID.random_create.to_s
        repository = RepositoryChooser.choose
        repository.store_file(zip_filename, 'delayed', random_uid, nil) #store file in a directory
        job.update_attributes :state => 'complete', :exit_params => ({:basename => basename, :random_uid => random_uid}).to_json
      rescue ShowAlertAndGoBack => e
        job.update_attributes :state => 'error', :error_explanation => e.message
        return
      end
    end
    
    
    def self.get_content_documents_with_updated_descriptions(book_directory, contents_filenames, current_library)

      begin
        # preload working data

        # load OPF to get book ID
        xml =  File.read(EpubUtils.get_contents_xml_name(book_directory)) 
        doc = Nokogiri::XML xml
        book_uid = EpubUtils.extract_book_uid(doc)
        @book_uid = book_uid

        # determine if there are descriptions
        if get_description_count_for_book_uid(book_uid, current_library) == 0
          raise NoImageDescriptions.new
        end

        # load descriptions into hash
        book = Book.where(:uid => book_uid, :library_id => current_library.id, :deleted_at => nil).first
        matching_images = DynamicImage.where("book_id = ?", book.id).all
        matching_images_hash = Hash.new()
        matching_images.each do | dynamic_image |
           matching_images_hash[dynamic_image.image_location] = dynamic_image
        end

        # loop over content filenanmes
        content_documents = {}

        contents_filenames.each do |cf|
          content_file = File.read(cf)
          content_doc = Nokogiri::XML content_file
          content_documents[get_relative_path(book_directory, cf)] = get_contents_with_updated_descriptions(content_doc, File::basename(cf, '.xhtml'), matching_images_hash)
        end
      rescue NoImageDescriptions
        Rails.logger.info "No descriptions available #{contents_filenames}"
        raise ShowAlertAndGoBack.new("There are no image descriptions available for this book")
      rescue MissingBookUIDException => e
        Rails.logger.info "Uploaded EPUB without Publication ID #{contents_filenames}"
        raise ShowAlertAndGoBack.new("Uploaded EPUB XML content file must have a Publication ID element")
      rescue Nokogiri::XML::XPath::SyntaxError => e
        Rails.logger.info "Uploaded file must contain a valid EPUB Content Document #{contents_filenames}"
        Rails.logger.info "#{e.class}: #{e.message}"
        Rails.logger.info "Line #{e.line}, Column #{e.column}, Code #{e.code}"
        raise ShowAlertAndGoBack.new("Uploaded file must contain a valid EPUB Content Document")
      rescue Exception => e
        Rails.logger.info "Unexpected exception processing #{contents_filenames}:"
        Rails.logger.info "#{e.class}: #{e.message}"
        Rails.logger.info e.backtrace.join("\n")
        $stderr.puts e
        raise ShowAlertAndGoBack.new("An unexpected error has prevented processing that file")
      end
      return content_documents
    end
    
    def self.create_zip(old_file_zip, content_documents)
      new_file_zip = Tempfile.new('baked-book')
      new_file_zip.close
      FileUtils.cp(old_file_zip, new_file_zip.path)
      Zip::Archive.open(new_file_zip.path) do |zipfile|
        zipfile.num_files.times do |index|
          if(content_documents.keys.include? zipfile.get_name(index))
            zipfile.replace_buffer(index, content_documents[zipfile.get_name(index)])
          end
        end
      end
      return new_file_zip.path
    end
    
    def get_description_count_for_book_uid(book_uid, current_library)
      DaisyBookHelper::BatchHelper.get_description_count_for_book_uid(book_uid, current_library)
    end
    def self.get_description_count_for_book_uid(book_uid, current_library)
      return DynamicImage.
          joins(:book).
          where(:books => {:uid => book_uid, :library_id => current_library.id, :deleted_at => nil}).
          count
    end
    
    def self.get_contents_with_updated_descriptions(doc, filename, image_hash)
      # brute-force: remove aria-describedby attributes that reference Poet-injected elements
      doc.css('img[aria-describedby^="' + ASIDE_PREFIX + '"]').remove_attr('aria-describedby')

      # brute-force: remove Poet-injected aside elements
      doc.css('aside[id^="' + ASIDE_PREFIX + '"]').remove

      seq = 1

      doc.css('img').each do |img_node|
        unless (img_node['src']).blank?
          image_location = EpubUtils.sanitize_image_location(img_node['src'])
          dynamic_image = image_hash[image_location]
          unless dynamic_image == nil 
            # Attach any alt text modifications that might exist
            alt = dynamic_image.current_alt
            if (alt && alt.alt)
              img_node['alt'] = alt.alt
            end

            # Attempt to find the parent container of the image node
            imggroup = get_imggroup_parent_of(img_node)
            
            # Replace the image if there is an equation
            if (book.math_replacement_mode_id == MathReplacementMode.MathML.id && dynamic_image.image_category_id == ImageCategory.MathEquations.id && dynamic_image.current_equation && dynamic_image.current_equation.element)
              math_element = MathHelper.create_math_element(dynamic_image.current_equation)
              image_element = imggroup ? imggroup : img_node
              MathHelper.replace_math_image(image_element, math_element, img_node['src'])
              Rails.logger.info "Image #{image_location} was removed in favor or equation #{dynamic_image.current_equation.id}"
              next
            end
            
            dynamic_description = dynamic_image.dynamic_description
            if(!dynamic_description || !dynamic_description.body || dynamic_description.body.strip.length == 0)
              Rails.logger.info "Image #{@book_uid} #{image_location} is in database but with no descriptions"
              next
            end

            aside_id = (ASIDE_PREFIX + filename + "_%06d") % seq

            # inject a node
            aside_node = Nokogiri::XML::Node.new "aside", doc
            aside_node.add_child dynamic_description.body
            aside_node['epub:type'] = 'annotation'
            aside_node['id'] = aside_id
            img_node['aria-describedby'] = aside_id
            img_node.add_next_sibling aside_node

            seq += 1
          end
        end   
      end
      return doc.to_xml
    end
    
    def self.get_imggroup_parent_of(image_node)
      parent = image_node.parent
      if (!parent || parent.node_name != 'div')
        return nil
      end 
      
      return parent
    end
    
    def self.get_relative_path(root_dir, path)
      rp = path[root_dir.length..-1]
      if (rp[0] == File::SEPARATOR)
        rp = rp[1..-1]
      end
      return rp
    end
    
  end
end
