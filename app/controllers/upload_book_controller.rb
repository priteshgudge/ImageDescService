require 'fileutils'
require 'nokogiri'
require 'tempfile'
include DaisyUtils, UnzipUtils, EpubUtils
include ActionView::Helpers::NumberHelper


class NoImageDescriptions < Exception
end

class NonDaisyXMLException < Exception
end

class MissingBookUIDException < Exception
end

class ShowAlertAndGoBack < Exception
  def initialize(message)
    @message = message
  end

  attr_reader :message
end

class UploadBookController < ApplicationController
  before_filter :authenticate_user!

  ROOT_XPATH = "/xmlns:dtbook"
  include RepositoryChooser

  def initialize
    super
    @repository = RepositoryChooser.choose
  end


  def submit
    #init session vars
    session[:book_id] = nil
    session[:content] = nil
    session[:daisy_directory] = nil
    file_type = nil
    
    book = params[:book]
    if !book
      flash[:alert] = "Must specify a book file to upload"
      redirect_to :action => 'upload'
      return
    end

    begin
      if valid_daisy_zip?(book.path)
        file_type = "Daisy"
      elsif valid_epub_zip?(book.path)
        # to do - when turning on the upload for EPUB files we need to check the deleted_at flag
        file_type = "Epub"
      else  
        redirect_to :action => 'upload'
        return
      end 

    rescue Exception => e
        logger.info "#{e.class}: #{e.message}"
        if e.message.include?("Not a zip archive")
            logger.info "#{caller_info} Not a ZIP File"
            flash[:alert] = "Uploaded file must be a valid DAISY or EPUB 3 file"
        else
            logger.info "#{caller_info} Other problem with zip file"
            flash[:alert] = "There is a problem with this zip file"
        end
        puts e
        puts e.backtrace.join("\n")
        redirect_to :action => 'upload'
        return false
    end   

    begin
      zip_directory, book_directory, file = accept_and_copy_book(book.path, file_type) #store filetype bookstable
      xml = get_xml_from_dir book_directory, file_type
      doc = Nokogiri::XML xml
      @book_uid = extract_book_uid(doc, file_type)
      doc = nil
      xml = nil
     
      preprocessing_book = Book.where(:uid => @book_uid, :deleted_at => nil).first
      if preprocessing_book && preprocessing_book.status == 4
        flash[:alert] = "The book (#{@book_uid}) is still being processed. Please try again later."
        redirect_to :action => 'upload'
        return
      end
      #uploading a book that has been deleted uid number unique? look into this TODO
      this_book = Book.where(:uid => @book_uid, :file_type => file_type, :deleted_at => nil).first
      if this_book
        flash[:alert] = "The #{file_type} book (#{@book_uid}) has already been uploaded."
        redirect_to :action => 'upload'
        return
      end

      if !preprocessing_book
         preprocessing_book = Book.create(:uid => @book_uid, :file_type => file_type, :status => 4, :library =>  current_library, :user_id => current_user.id)
      end

      pid = fork do
        begin
          @repository.store_file(book.path, @book_uid, @book_uid + ".zip", nil)
          job = nil
          if file_type == "Epub"
            job = EpubParser.new(preprocessing_book.id, @repository.name, current_library, current_user.id)
          else
            job = DaisyParser.new(preprocessing_book.id, @repository.name, current_library, current_user.id)
          end

        job.perform
          # Delayed::Job.enqueue(job)
          # 
          # # hack for testing
          # if (Rails.env.test?)
          #   Delayed::Worker.new.work_off
          # end

        rescue AWS::Errors::Base => e
          logger.info "S3 Problem uploading book to S3 for book #{@book_uid}"
          logger.info "#{e.class}: #{e.message}"
          logger.info "Line #{e.line}, Column #{e.column}, Code #{e.code}"
          flash[:alert] = "There was a problem uploading"
          redirect_to :action => 'upload'
          return
        rescue Exception => e
          logger.info "Unknown problem uploading book to S3 for book #{@book_uid}"
          logger.info "#{e.class}: #{e.message}"
          logger.info e.backtrace.join("\n")
          $stderr.puts e
          flash[:alert] = "There was a problem uploading"
          redirect_to :action => 'upload'
          return
        end
      end
      Process.detach(pid)

      render 'display_uid'

    rescue Zip::Error => e
      logger.info "#{e.class}: #{e.message}"
      if e.message.include?("File encrypted")
        logger.info "#{request.remote_addr} Password needed for zip"
        flash[:alert] = "Please enter a password for this book"
      else
        logger.info "#{request.remote_addr} Other problem with zip"
        flash[:alert] = "There is a problem with this zip file"
      end

      redirect_to :action => 'upload'
      return
    end
  end

end