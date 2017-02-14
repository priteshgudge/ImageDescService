class FileController < ApplicationController
  def file
    directory_name = params[:directory]
    if !directory_name
      directory_name = ''
    end
    extension = params[:format]
    if !extension
      extension = ''
    else
      extension = '.' + extension
    end
    file_name = params[:file]
    book_directory = ENV['POET_LOCAL_STORAGE_DIR']

    directory = File.join(book_directory, directory_name)
    file = File.join(directory, "#{file_name}#{extension}")
    timestamp = File.stat(file).ctime
    if(stale?(:last_modified => timestamp))
      content_type = 'text/plain'
      case File.extname(file).downcase
      when '.jpg', '.jpeg'
        content_type = 'image/jpeg'
      when '.png'
        content_type = 'image/png'
      when '.svg'
        content_type = 'image/svg+xml'
      end
      contents = File.read(file)
      response.headers['Last-Modified'] = timestamp.httpdate
      render :text => contents, :content_type => content_type
    end
  end
end