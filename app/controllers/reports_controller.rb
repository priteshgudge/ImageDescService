class ReportsController < ApplicationController
  before_filter :authenticate_user!
  include ActionView::Helpers::NumberHelper

  def index

    @books_total = Book.connection.select_value("select count(id) from books where id in (select distinct(book_id) from dynamic_descriptions) and deleted_at is null")
    #@descriptions_total = DynamicDescription.connection.select_value("select count(id) from dynamic_descriptions")
    @book_stats = BookStats.joins(:book).where('deleted_at is null').order('books.title').all
    @total_essential_images = BookStats.sum("total_essential_images")
    @total_images_described = BookStats.sum("total_images_described")
    @total_essential_images_described = BookStats.sum("essential_images_described")
    @total_images = BookStats.sum("total_images")

  end

  def view_book

    book_id = params[:book_id]

    if(!book_id || book_id.length == 0)
      flash[:alert] = "Must specify a book ID"
      redirect_to :action => 'index'
      return
    end

    @book = Book.find(book_id.strip) rescue nil
    if(!@book)
      flash[:alert] = "There is no book in the system with that ID (#{book_id}) ."
      redirect_to :action => 'index'
      return
    end

    @descriptions_total = DynamicDescription.connection.select_value("select count(id) from dynamic_descriptions where book_id = '#{book_id}'")
    @images_described = DynamicDescription.connection.select_value("select count(distinct(dynamic_image_id)) from dynamic_descriptions where book_id = '#{book_id}'")
    @images_total = DynamicImage.connection.select_value("select count(id) from dynamic_images where book_id = '#{book_id}'")
    @description_still_needed  = DynamicImage.connection.select_value("SELECT count(id) FROM dynamic_images WHERE book_id = '#{book_id}' and should_be_described = true and id not in (select dynamic_image_id from dynamic_descriptions where dynamic_descriptions.book_id = '#{book_id}') ORDER BY id ASC;")
    @essential_images_total = DynamicImage.connection.select_value("select count(id) from dynamic_images where book_id = '#{book_id}' and should_be_described = true")

  end

  def update_book_stats

    job = UpdateReportsJob.new
    Delayed::Job.enqueue(job)

    render :text => 'updating reports data'
  end

  def describer_list
     submitters = DynamicDescription.connection.select_rows("select submitter_id, count(*) as total from dynamic_descriptions group by submitter_id order by total desc;")
     @submitter_list =[]
     submitters.each do |submitter_id, count|
         submitter = User.where(:id => submitter_id, :deleted_at => nil).first
         if submitter 
           if submitter.full_name && !submitter.full_name.blank?
             name = submitter.full_name
           else
             name = submitter.username
           end 
           submitter_count = [name, count] 
           @submitter_list << submitter_count if submitter_count
         end
      end
  end
  
  def report_all
    ## total images by book
    ## select book_id, count(book_id) from dynamic_images group by book_id;

    ## essential images by book
    ## select book_id, count(book_id) from dynamic_images where should_be_described = true group by book_id;

    ## described images by book
    ## select book_id, count(distinct(dynamic_image_id)) from dynamic_descriptions group by book_id;
  end

end