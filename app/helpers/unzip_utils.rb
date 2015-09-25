module UnzipUtils
  
  def accept_and_copy_book(book_path, file_type)
    UnzipUtils.accept_and_copy_book(book_path, file_type)
  end
  def unzip_to_temp(zipped_file)
    UnzipUtils.unzip_to_temp(zipped_file)
  end

  def get_xml_from_dir book_directory = nil, file_type = nil
    UnzipUtils.get_xml_from_dir(book_directory, file_type)
  end
  
  
  def self.accept_and_copy_book(book_path, file_type)
    zip_directory = unzip_to_temp(book_path)
    top_level_entries = Dir.entries(zip_directory)
    top_level_entries.delete('.')
    top_level_entries.delete('..')
    if(top_level_entries.size == 1)
      book_directory = File.join(zip_directory, top_level_entries.first)
    else
      book_directory = zip_directory      
    end
    copy_of_file = File.join(zip_directory,  file_type + ".zip")
    FileUtils.cp(book_path, copy_of_file)

    return zip_directory, book_directory, copy_of_file
  end

  def self.unzip_to_temp(zipped_file)
    dir = Dir.mktmpdir
    Zip::Archive.open(zipped_file) do |zipfile|
      zipfile.each do |entry|
        destination = File.join(dir, entry.name)
        if entry.directory?
          FileUtils.mkdir_p(destination)
        else
          dirname = File.join(dir, File.dirname(entry.name))
          FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
          open(destination, 'wb') do |f|
            f << entry.read
          end
        end
      end
    end
    return dir
  end
  
  def extract_book_title(doc, file_type)
    book_title = nil
    if file_type == "Epub"  
       book_title = EpubUtils.extract_book_title doc
     else
       book_title = DaisyUtils.extract_book_title doc
     end
  end
  
  def get_file_type filename
    if filename=~/\.epub$/
       file_type = "Epub"
    else
       file_type = "Daisy"
    end
  end
  
  def extract_book_uid book, file_type = nil
    book_uid = nil
    if file_type == "Epub"  
      book_uid = EpubUtils.extract_book_uid book
    else
      book_uid = DaisyUtils.extract_book_uid book
    end
  end
  
  
  def self.get_xml_from_dir book_directory = nil, file_type = nil
    if file_type == "Epub"
       contents_filename = EpubUtils.get_contents_xml_name(book_directory) 
    else
       contents_filename = DaisyUtils.get_contents_xml_name(book_directory) 
    end 
    File.read(contents_filename)
  end
  
  def extract_images_prod_notes doc, file_type, book_directory = nil
    if file_type == "Epub"
      extract_images_prod_notes_for_epub doc, book_directory
    else
      extract_images_prod_notes_for_daisy doc
    end 
  end
  

end