class DynamicImagesController < ApplicationController

  # GET /dynamic_images/1
  # GET /dynamic_images/1.xml
  # GET /dynamic_images/1.json
  def edit
    book = load_book
    if params[:image_location] && book
      @dynamic_image = DynamicImage.where(:book_id => book.id, :image_location => params[:image_location]).first
      if @dynamic_image
        @last_desc = @dynamic_image.dynamic_description
      else
        @last_desc = DynamicDescription.new
        @last_desc.body = "no description found"
        @status = :no_content
      end
    else
      @last_desc = DynamicDescription.new
      @last_desc.body = "missing parameter book_id=#{book.id}, loc=#{params[:image_location]}"
      @status = :non_authoritative_information
    end

    respond_to do |format|
      if @dynamic_image
        format.html # show.html.erb
        format.xml  { render :xml => @last_desc }
        format.json { render :json => @last_desc, :callback => params[:callback]}
      else
        format.html
        format.xml { render :xml => @last_desc, :status => @status}
        format.json { render :json => @last_desc, :callback => params[:callback], :status => @status}
      end
    end
  end

  def show_history
    book = load_book
    if params[:image_location] && book
      @descriptions = DynamicDescription.joins(:dynamic_image).where(:book_id => book.id, :dynamic_images => {:image_location => params[:image_location]}).order('created_at desc').all
      render :layout => false
    end

  end

  # GET /dynamic_images/new
  # GET /dynamic_images/new.xml
  def new
    @dynamic_image = DynamicImage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dynamic_image }
    end
  end

  # GET /dynamic_images/1/show
  def show
    render :json => JSON.parse(DynamicImage.find(params[:id]).to_json(:host => @host, :include => :dynamic_description))
  end

  # POST /dynamic_images
  # POST /dynamic_images.xml
  def create
    @dynamic_image = DynamicImage.new(params[:dynamic_image])

    respond_to do |format|
      if @dynamic_image.save
        format.html { redirect_to(@dynamic_image, :notice => 'Image description successfully entered!') }
        format.xml  { render :xml => @dynamic_image, :status => :created, :location => @dynamic_image }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dynamic_image.errors, :status => :not_found }
      end
    end
  end
  
  def update
    image = DynamicImage.find(params[:id])
    image_params = params[:dynamic_image]
    image.should_be_described = params[:should_be_described]
    image.image_category_id = params[:image_category_id]
    image.save
    render :text=>"submitted #{params[:id]}: #{params[:dynamic_image]}",  :content_type => 'text/plain'
  end

  def mark_all_essential
    book = load_book
    if book
      DynamicImage.update_all({:should_be_described => true}, {:book_id => book.id})
      render :text=>"submitted #{params[:id]}: #{params[:dynamic_image]}",  :content_type => 'text/plain'
    end
  end
  
  def category_sample_html_page
    image_category = ImageCategory.find(params[:id])
    if image_category 
        send_file  "#{Rails.root}/public/#{image_category.sample_file_name}"
    end
  end
end