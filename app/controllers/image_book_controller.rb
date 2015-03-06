require 'fileutils'
require 'nokogiri'
require 'tempfile'
include ActionView::Helpers::NumberHelper
include DaisyUtils, UnzipUtils, EpubUtils

class ImageBookController < ApplicationController
  before_filter :authenticate_user!
  ROOT_XPATH = "/xmlns:dtbook"

  def initialize
    super()
    @repository = RepositoryChooser.choose
  end

  def check_image_coverage
    file_type = nil
    book = params[:book]
    if !book
      flash[:alert] = "Must specify a book file to check"
      redirect_to :action => 'image_check'
      return
    end
    begin
      if valid_daisy_zip?(book.path)
        file_type = "Daisy"
      elsif valid_epub_zip?(book.path)
        file_type = "Epub"
      else
        flash[:alert] = "Not a valid DAISY or EPUB book"
        redirect_to :action => 'image_check'
        return
      end
      zip_directory, book_directory, daisy_file = accept_and_copy_book(book.path, file_type)
      display_image_coverage zip_directory, book_directory, file_type
    
    rescue Zip::Error => e
      logger.info "#{e.class}: #{e.message}"
      logger.info "#{caller_info} Other problem with zip"
      flash[:alert] = "There is a problem with this file"
      redirect_to :action => 'image_check'
      return
    end

  end
  
  def submit_to_get_descriptions
    book = params[:book]
    password = params[:password]
    if !book
      flash[:alert] = "Must specify a book file to process"
      redirect_to :action => 'process'
      return
    end
    
    begin
      # Store file in S3
      repository = RepositoryChooser.choose
      random_uid = UUIDTools::UUID.random_create.to_s
      @repository.store_file(book.path, 'delayed', random_uid, nil) #store file in a directory
      @job = Job.new({:user_id => current_user.id, :enter_params => ({:random_uid => random_uid, :password => password, :book_name => book.original_filename, :content_type => book.content_type}).to_json})
      @job.save
    
      @file_type = get_file_type book.original_filename
      zip_directory, book_directory, file = accept_and_copy_book(book.path, @file_type)
      xml = get_xml_from_dir book_directory, @file_type
      doc = Nokogiri::XML xml
      @book_uid = extract_book_uid(doc, @file_type)
      @book_title = extract_book_title(doc, @file_type)

      if @file_type == "Epub"
        EpubBookHelper::BatchHelper.delay.batch_add_descriptions_to_book(@job.id, current_library)
      else
        DaisyBookHelper::BatchHelper.delay.batch_add_descriptions_to_book(@job.id, current_library) 
      end

    rescue Zip::Error => e
      logger.info "#{e.class}: #{e.message}"
      logger.info "#{caller_info} Other problem with zip"
      flash[:alert] = "There is a problem with this file"
      redirect_to :action => 'process'
      return
    end
    
  end
  
  def display_image_coverage zip_directory, book_directory, file_type
    begin
      contents_filename = nil
      @host = @repository.get_host(request)
      xml_file = get_xml_from_dir(book_directory, file_type)
      
      begin
        doc = Nokogiri::XML xml_file
        root = doc.xpath(doc, ROOT_XPATH)
        @book_title = extract_book_title(doc, file_type)
        extract_images_prod_notes doc, file_type, book_directory
        
      # rescue NonDaisyXMLException => e
      #   logger.info "#{caller_info} Uploaded non-dtbook #{contents_filename}"
      #   raise ShowAlertAndGoBack.new("Uploaded file must be a valid Daisy book XML content file")
      end
    end
  end
  

  def poll_file_with_descriptions
    job = Job.where(:id => params[:job_id], :user_id => current_user.id).first
    ActiveRecord::Base.include_root_in_json = false
    render :json => JSON.parse(job.to_json)
  end
  
  def download_with_descriptions
    job = Job.where(:id => params[:job_id], :user_id => current_user.id).first
    repository = RepositoryChooser.choose
    file_ext = params[:file_type] == "Epub" ? ".epub" : ".zip"
    
    if job && job.state == 'complete'
      exit_params = job.json_exit_params
      random_uid = exit_params['random_uid']
      basename = exit_params['basename']
      random_uid_book_location = repository.read_file(random_uid, File.join( "", "tmp", "#{random_uid}.zip"))
      send_file random_uid_book_location, :type => 'application/zip; charset=utf-8', :filename => basename + file_ext, :disposition => 'attachment' 
    else
      render :text => "Not Complete"
    end
  end
  
end
