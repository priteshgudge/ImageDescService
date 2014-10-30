class S3Repository
  require 'find'

  SECONDS_IN_DAY = 86400

  def self.store_file (file_path, book_uid, new_file_name, s3_service)
        bucket_name = ENV['POET_ASSET_BUCKET']
        if (!s3_service)
          # get handle to s3 service
          s3_service = AWS::S3.new
        end
        # get an s3 bucket
        bucket = s3_service.buckets[bucket_name]

        s3_object = bucket.objects[new_file_name]
        begin
          if(File.exists?(file_path))
            s3_object.write(:file => file_path)
          else
            puts("file does not exist in local dir #{file_path}")
            s3_object = nil
          end
        rescue AWS::Errors::Base => e
          puts "S3 Problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts "Line #{e.line}, Column #{e.column}, Code #{e.code}"
        rescue Exception => e
          puts "Unknown problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
          $stderr.puts e
        end
  end
  
  def self.generate_file_path(book_uid, file_name, expires = 600)
      # get handle to s3 service
      s3_service = AWS::S3.new
      # get an s3 bucket
      bucket = s3_service.buckets[ENV['POET_ASSET_BUCKET']]
      s3_object = bucket.objects[book_uid + "/" + file_name]
      if (s3_object.exists?)
        s3_object.url_for(:read, {:expires => expires, :secure => true}).to_s if s3_object
      else
        return nil
      end
  end
  
  def self.read_file(file_path, new_local_file)
      begin
        # get handle to s3 service
        s3_service = AWS::S3.new

        # get s3 bucket to download zip file
        bucket = s3_service.buckets[ENV['POET_ASSET_BUCKET']]
        s3_object = bucket.objects[file_path]
        File.open(new_local_file, 'wb') {|f| f.write(s3_object.read) }
      end
      return new_local_file
  end

  def self.remove_file(file_path)
      bucket_name = ENV['POET_ASSET_BUCKET']
      begin
        # get handle to s3 service
        s3_service = AWS::S3.new

        # get s3 bucket to download zip file
        bucket = s3_service.buckets[bucket_name]
        s3_object = bucket.objects[file_path]
        s3_object.delete
        rescue AWS::Errors::Base => e
          puts "S3 Problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts "Line #{e.line}, Column #{e.column}, Code #{e.code}"
        rescue Exception => e
          puts "Unknown problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
          $stderr.puts e
      end
  end

  def self.cleanup(older_than_days)
    num_seconds = older_than_days * SECONDS_IN_DAY
    begin
      each_book() do | bucket, contents, book_uid |
        remove_files(bucket, contents, book_uid, num_seconds)
      end

      rescue AWS::Errors::Base => e
        puts "S3 Problem removing book from S3"
        puts "#{e.class}: #{e.message}"
        puts "Line #{e.line}, Column #{e.column}, Code #{e.code}"
      rescue Exception => e
        puts "Unknown problem removing book from S3"
        puts "#{e.class}: #{e.message}"
        puts e.backtrace.join("\n")
        $stderr.puts e
    end
  end

  def self.remove_cached_htmls()
    begin
      each_book() do | bucket, contents, book_uid |
        remove_cached_html(bucket, book_uid)
      end

      rescue AWS::Errors::Base => e
        puts "S3 Problem removing book from S3"
        puts "#{e.class}: #{e.message}"
        puts "Line #{e.line}, Column #{e.column}, Code #{e.code}"
      rescue Exception => e
        puts "Unknown problem removing book from S3"
        puts "#{e.class}: #{e.message}"
        puts e.backtrace.join("\n")
        $stderr.puts e
    end
  end

  def self.xslt(xml, xsl)
    document = Nokogiri::XML(xml)
    transformer = Nokogiri::XSLT(xsl)
    return transformer.transform(document)
  end

  def self.get_cached_html(book_uid, file_name)
      # get handle to s3 service
      s3_service = AWS::S3.new
      # get an s3 bucket
      bucket = s3_service.buckets[ENV['POET_ASSET_BUCKET']]
      s3_object = bucket.objects[book_uid + "/" + file_name]
      if (s3_object.exists?)
        s3_object.read
      else
        return nil
      end
  end

  def self.get_host(request)
    return "//" + ENV['POET_ASSET_BUCKET'] + ".s3.amazonaws.com" 
  end

private

  def self.each_book()
    bucket_name = ENV['POET_ASSET_BUCKET']
    begin
      # get handle to s3 service
      s3_service = AWS::S3.new

      bucket = s3_service.buckets[bucket_name]
      tree = bucket.as_tree
      tree.children.each do |book_dir|
        book_uid = book_dir.prefix.chop
        puts "book_uid is #{book_uid}"
        contents = book_dir.children
        yield(bucket, contents, book_uid)
      end

      rescue AWS::Errors::Base => e
        puts "S3 Problem removing book from S3"
        puts "#{e.class}: #{e.message}"
        puts "Line #{e.line}, Column #{e.column}, Code #{e.code}"
      rescue Exception => e
        puts "Unknown problem removing book from S3"
        puts "#{e.class}: #{e.message}"
        puts e.backtrace.join("\n")
        $stderr.puts e
    end
  end

  def self.remove_files(bucket, contents, book_uid, num_seconds)
    db_updated = false
    contents.each do |content|
      if (content.leaf?)
        s3_object = bucket.objects[content.key]
        if (Time.now - s3_object.last_modified > num_seconds)
          if (! db_updated)
            book = Book.where(:uid => book_uid, :deleted_at => nil).first
            book.update_attribute("status", 0)
            db_updated = true
          end
          s3_object.delete
        else
          break
        end
      else
        remove_files(bucket, content.children, book_uid, num_seconds)
      end
    end
  end

  def self.remove_cached_html(bucket, book_uid)
    s3_object = bucket.objects[book_uid + "/" + book_uid + ".html"]
    if (s3_object.exists?)
      book = Book.where(:uid => book_uid, :deleted_at => nil).first
      
      book.update_attribute("status", 0)
      s3_object.delete
    end
  end

end