module DaisyBookHelper
  class BatchHelper
    ROOT_XPATH = "/xmlns:dtbook"

    def self.batch_add_descriptions_to_book job_id, current_library 
      job = Job.where(:id => job_id).first
      # Retrieve file from S3
      repository = RepositoryChooser.choose
      enter_params = job.json_enter_params
      password = enter_params['password']
      random_uid = enter_params['random_uid']
      Rails.logger.info "Reading file from repository at #{random_uid}"
      random_uid_book_location = repository.read_file(random_uid, File.join( "", "tmp", "#{random_uid}.zip"))

      zip_directory, book_directory, daisy_file = UnzipUtils.accept_and_copy_book(random_uid_book_location, "Daisy")
      book = File.open daisy_file

      unless password.blank?
        Zip::Archive.decrypt(book.path, password)
      end

      if !DaisyUtils.valid_daisy_zip?(book.path)
        Exception.new "Not a valid DAISY book"
      end
      
      get_daisy_with_descriptions zip_directory, book_directory, daisy_file, job, current_library
    end
    
  
    def self.get_daisy_with_descriptions zip_directory, book_directory, daisy_file, job, current_library
      begin
        contents_filename = DaisyUtils.get_contents_xml_name(book_directory)
        relative_contents_path = contents_filename[zip_directory.length..-1]
        if(relative_contents_path[0,1] == '/')
          relative_contents_path = relative_contents_path[1..-1]
        end
        
        Rails.logger.info "Getting XML contents with descriptions from #{book_directory}"
        xml = get_xml_contents_with_updated_descriptions(contents_filename, current_library)

        # If we added Math to this, the OPF needs to be updated
        opf_filename = DaisyUtils.get_opf_name(book_directory)
        relative_opf_path = File.basename opf_filename
        
        opf = MathHelper.get_opf_contents_for_math(opf_filename, xml)
        
        zip_filename = create_zip(daisy_file, relative_contents_path, xml, relative_opf_path, opf)

        basename = File.basename(contents_filename)
        Rails.logger.info "Sending zip #{zip_filename} of length #{File.size(zip_filename)}"
      
        # Store this file in S3, update the Job; change exit_params and the state
        random_uid = UUIDTools::UUID.random_create.to_s
        repository = RepositoryChooser.choose
        repository.store_file(zip_filename, 'delayed', random_uid, nil)
        job.update_attributes :state => 'complete', :exit_params => ({:basename => basename, :random_uid => random_uid}).to_json
      rescue ShowAlertAndGoBack, Exception => e
        Rails.logger.info "#{e.class}: #{e.message}"
        job.update_attributes :state => 'error', :error_explanation => e.message
        return
      end
    end

    
    def self.get_xml_contents_with_updated_descriptions(contents_filename, current_library)
      xml_file = File.read(contents_filename)
      begin
        xml = get_contents_with_updated_descriptions(xml_file, current_library)
      rescue NoImageDescriptions
        Rails.logger.info "No descriptions available #{contents_filename}"
        raise ShowAlertAndGoBack.new("There are no image descriptions available for this book")
      rescue NonDaisyXMLException => e
        Rails.logger.info "Uploaded non-dtbook #{contents_filename}"
        raise ShowAlertAndGoBack.new("Uploaded file must be a valid Daisy book XML content file")
      rescue MissingBookUIDException => e
        Rails.logger.info "Uploaded dtbook without UID #{contents_filename}"
        raise ShowAlertAndGoBack.new("Uploaded Daisy book XML content file must have a UID element")
      rescue Nokogiri::XML::XPath::SyntaxError => e
        Rails.logger.info "Uploaded invalid XML file #{contents_filename}"
        Rails.logger.info "#{e.class}: #{e.message}"
        Rails.logger.info "Line #{e.line}, Column #{e.column}, Code #{e.code}"
        raise ShowAlertAndGoBack.new("Uploaded file must be a valid Daisy book XML content file")
      rescue Exception => e
        Rails.logger.info "Unexpected exception processing #{contents_filename}:"
        Rails.logger.info "#{e.class}: #{e.message}"
        Rails.logger.info e.backtrace.join("\n")
        $stderr.puts e
        raise ShowAlertAndGoBack.new("An unexpected error has prevented processing that file")
      end

      return xml
    end
    
    def self.create_zip(old_daisy_zip, contents_filename, new_xml_contents, 
                      opf_filename, new_opf_contents)
      new_daisy_zip = Tempfile.new('baked-daisy')
      new_daisy_zip.close
      FileUtils.cp(old_daisy_zip, new_daisy_zip.path)
      Zip::Archive.open(new_daisy_zip.path) do |zipfile|
        zipfile.num_files.times do |index|
          if (zipfile.get_name(index) == contents_filename)
            zipfile.replace_buffer(index, new_xml_contents)
          end
          if (zipfile.get_name(index) == opf_filename)
            zipfile.replace_buffer(index, new_opf_contents)
          end
        end
        
        if MathHelper.contains_math(new_xml_contents)
          zipfile.add_or_replace_file(MathHelper::MATHML_FALLBACK_FILE, "public/#{MathHelper::MATHML_FALLBACK_FILE}")
        end
      end
      return new_daisy_zip.path
    end
    
    def get_description_count_for_book_uid(book_uid, current_library)
      DaisyBookHelper::BatchHelper.get_description_count_for_book_uid(book_uid, current_library)
    end
    def self.get_description_count_for_book_uid(book_uid, current_library)
      return DynamicImage.
          joins(:book).
          where(:books => {:uid => book_uid, :library_id => current_library.id}).
          count
    end
    
    def get_contents_with_updated_descriptions(file, current_library)
      DaisyBookHelper::BatchHelper.get_contents_with_updated_descriptions(file, current_library)
    end

    def self.get_contents_with_updated_descriptions(file, current_library)
      doc = Nokogiri::XML file

      # TODO: Do we really need this? If we're checking validity, there would
      # be much more we would want to check
      get_doc_root(doc)

      book_uid = DaisyUtils.extract_book_uid(doc)

      if get_description_count_for_book_uid(book_uid, current_library) == 0
        raise NoImageDescriptions.new
      end

      book = Book.where(:uid => book_uid, :library_id => current_library.id, :deleted_at => nil).first
      matching_images = DynamicImage.where("book_id = ?", book.id).all
      matching_images.each do | dynamic_image |
        image_location = dynamic_image.image_location

        image_references = doc.xpath("//xmlns:img[@src='#{image_location}']")
        if image_references.size == 0
          Rails.logger.info "Missing img element for database description #{book_uid} #{image_location}"
          next
        end

        image_references.each do |img_node|
          # Attach any alt text modifications that might exist
          if (dynamic_image.current_alt && dynamic_image.current_alt.alt)
            img_node['alt'] = dynamic_image.current_alt.alt
          end
          
          # Attempt to find the parent imggroup
          imggroup = get_imggroup_parent_of(img_node)

          # Replace the image if there is an equation
          if (book.math_replacement_mode_id == MathReplacementMode.MathMLMode.id && dynamic_image.image_category_id == ImageCategory.MathEquations.id && dynamic_image.current_equation && dynamic_image.current_equation.element)
            math_element = MathHelper.create_math_element(dynamic_image.current_equation)
            image_element = imggroup ? imggroup : img_node
            MathHelper.replace_math_image(image_element, math_element, img_node['src'])
            MathHelper.attach_math_extensions(doc)
            Rails.logger.info "Image #{book_uid} #{image_location} was removed in favor or equation #{dynamic_image.current_equation.id}"
            next
          end

          dynamic_description = dynamic_image.dynamic_description
          if (!dynamic_description)
            Rails.logger.info "Image #{book_uid} #{image_location} is in database but with no descriptions"
            next
          end

          # note that there's no guarantee this will be non-null
          image_id = img_node['id']

          # Push down into an imggroup element if none already exists
          if (!imggroup)
            imggroup = Nokogiri::XML::Node.new "imggroup", doc
            parent = img_node.parent
            # could result in an ID collision
            imggroup['id'] =  "imggroup_#{image_id}"
            imggroup.parent = parent

            parent.children.delete(img_node)
            img_node.parent = imggroup
          end

          # Attempt to locate prodnote that conforms to our ID naming convention 
          prodnotes = imggroup.xpath(".//xmlns:prodnote")
          our_prodnote = nil
          prodnotes.each do | prodnote |
            if (prodnote['id'] == create_prodnote_id(image_id))
              # Found a match, keep it
              our_prodnote = prodnote
            end
          end

          # If not found, create a new one
          if (!our_prodnote)
            our_prodnote = Nokogiri::XML::Node.new "prodnote", doc 
            imggroup.add_child our_prodnote 
          end

          # flush old contents then append most recent ones
          our_prodnote.children.each do |child|
            child.remove
          end

          our_prodnote.add_child(dynamic_description.body)
          our_prodnote['render'] = 'optional'
          our_prodnote['imgref'] = image_id
          our_prodnote['id'] = create_prodnote_id(image_id)
          our_prodnote['showin'] = 'blp'
        end
      end

      return doc.to_xml
    end
    
    def create_prodnote_id(image_id)
      DaisyBookHelper::BatchHelper.create_prodnote_id(image_id)
    end

    def self.create_prodnote_id(image_id)
      "pnid_#{image_id}"
    end
    
    def get_imggroup_parent_of(image_node)
      DaisyBookHelper::BatchHelper.get_imggroup_parent_of(image_node)
    end

    def self.get_imggroup_parent_of(image_node)
      node = image_node
      prevent_infinite_loop = 100
      while(node)
        if(node.node_name == "imggroup")
          return node
        end
        parent = node.at_xpath("..")
        if(!parent || parent == node || parent.node_name == "dtbook")
          break
        end
        node = parent
        prevent_infinite_loop -= 1
        if(prevent_infinite_loop < 0)
          raise "XML file image was nested more than 100 levels deep"
        end
      end
      return nil
    end
    
    private
    def self.get_doc_root(doc)
      root = doc.xpath(doc, ROOT_XPATH)
      if root.size != 1
        raise NonDaisyXMLException.new
      end
      return root
    end
  end
end
