class S3UnzippingJob < Struct.new(:book_id, :repository_name, :library, :uploader_id)

  def enqueue(job)

  end
  
  IMAGE_LIMIT = 241

  def perform

  end

  def accept_book(book_path)
    zip_directory = unzip_to_temp(book_path)
    top_level_entries = Dir.entries(zip_directory)
    top_level_entries.delete('.')
    top_level_entries.delete('..')
    if top_level_entries.size == 1
      book_directory = File.join(zip_directory, top_level_entries.first)
    else
      book_directory = zip_directory
    end
  end

  def unzip_to_temp(zipped_file)
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
    dir
  end

  
  def create_images_in_database(book, fragment, book_directory, doc)
     each_image(doc) do | image_node |
      image_location = EpubUtils.sanitize_image_location(image_node['src'])
      xml_id = image_node['id']

      # if src exists
      if image_location

        # add image to db if it does not already exist in db
        image = DynamicImage.where(:book_id => book.id, :image_location => image_location).first
        image_path = get_image_path(book_directory, image_location)
        if !image && File.exists?(image_path)
          begin
            width, height = get_image_size(image_path)
            DynamicImage.create(
                  :book_id => book.id,
                  :book_fragment_id => fragment.id,
                  :width => width,
                  :height => height,
                  :xml_id => xml_id,
                  :physical_file => File.new(image_path, "rb"),
                  :image_location => image_location)
          rescue Exception => e
            book.update_attribute("status", 5) if book
            puts "Unknown problem creating dynamic image, #{image_location}, for book #{book.id}"
            puts "#{e.class}: #{e.message}"
            puts e.backtrace.join("\n")
            $stderr.puts e
            raise
          end
        elsif image
          # This should only happen on re-uploading of books in order to split existing books
          # or for images used multiple times in a book

          unless image.book_fragment_id
            image.update_attribute("book_fragment_id", fragment.id)
          end
        end
      end
    end
  end

  def each_image (doc)
   
  end

  def get_image_size(image_file)
    width, height = 20

    if File.exists?(image_file)
      open(image_file, "rb") do |fh|
          is = ImageSize.new(fh.read)
          width = is.width
          height = is.height
      end
    end

    return width, height
  end

  def before(job)
    puts 'before'
  end

  def after(job)
    puts 'after'
  end

  def success(job)
    puts "job successfully completed"
  end

  def error(job, exception)
    puts "#{exception.class}: #{exception.message}"
      puts exception.backtrace.join("\n")
      $stderr.puts exception
  end

  def failure
    puts "some sort of failure"
  end

  def unzip
    #another way to trigger a delayed job
  end

  def sanitize_image_location(image_location)
    image_location.gsub("../", "")
  end
    
  handle_asynchronously :unzip

end