class LocalRepository
  require 'find'

  def self.store_file (file_path, book_uid, new_file_name, s3_service)
      local_dir = choose_base_dir
      begin
        if (File.exists?(file_path))
          qualified_new_file = File.join(local_dir, new_file_name)

          if (qualified_new_file.eql?(file_path))
            return
          end

          dir = File.dirname(qualified_new_file)
          make_nested_dirs(dir, local_dir)

          FileUtils.copy_entry(file_path, qualified_new_file)
        else
          # puts "file does not exist in local dir #{file_path} for copy to local store"
        end
      rescue Exception => e
        puts "Unknown problem copying to local storage dir for book #{book_uid}"
        puts "#{e.class}: #{e.message}"
        puts e.backtrace.join("\n")
        $stderr.puts e
        raise
      end
  end

  def self.read_file(file_path, new_local_file)
      local_dir = choose_base_dir
      qualified_file = File.join(local_dir, file_path)

      if (qualified_file.eql?(new_local_file))
        return new_local_file
      end

      if (File.exists?(qualified_file))
        dir = File.dirname(new_local_file)
        if (! File.exists?(dir))
          Dir.mkdir(dir)
        end
        FileUtils.copy_entry(qualified_file, new_local_file)
      else
        puts ("local file  to read doesn't exist, #{qualified_file}'")
      end
      return new_local_file
  end

  def self.remove_file(file_path)
      local_dir = choose_base_dir
      File.delete(File.join(local_dir, file_path))
  end

  def self.choose_base_dir
    if (Rails.env.test?)
      return '/tmp'
    else
      return ENV['POET_LOCAL_STORAGE_DIR']
    end
  end

  def self.xslt(xml, xsl)
    document = Nokogiri::XML(xml)
    transformer = Nokogiri::XSLT(xsl)
    return transformer.transform(document)
  end

  def self.generate_file_path(book_uid, file_name, expires = 60)
    local_dir = ENV['POET_LOCAL_STORAGE_DIR']
    return File.join(local_dir, book_uid, file_name)
  end
  
  def self.get_cached_html(book_uid, file_name)
    local_dir = ENV['POET_LOCAL_STORAGE_DIR']
    return File.read(File.join(local_dir, book_uid, file_name))
  end

  def self.get_host(request)
    return "//" + request.host_with_port + "/file"
  end


  def self.make_nested_dirs (nested_dir, root_dir)
    dirs = nested_dir.split(File::SEPARATOR)
    root_dirs = root_dir.split(File::SEPARATOR)
    root_dir_nest = root_dirs.size
    new_dir = "";
    dirs.each_index do |i|
      dir = dirs[i]
      new_dir = File.join(new_dir, dir)
      if (i >= root_dir_nest)
        if (! File.exists?(new_dir))
          Dir.mkdir(new_dir)
        end
      end
    end
  end

end