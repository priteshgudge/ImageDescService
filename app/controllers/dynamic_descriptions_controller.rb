class DynamicDescriptionsController < ApplicationController
  before_filter :authenticate_user!
  # GET /dynamic_descriptions
  # GET /dynamic_descriptions.xml
  def initialize
    super()
    @repository = RepositoryChooser.choose
  end

  def index
    @dynamic_descriptions = DynamicDescription.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dynamic_descriptions }
    end
  end

  # GET /dynamic_descriptions/1
  # GET /dynamic_descriptions/1.xml
  def show

    @dynamic_description = DynamicDescription.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dynamic_description }
    end
  end

  # GET /dynamic_descriptions/new
  # GET /dynamic_descriptions/new.xml
  def new
    @dynamic_description = DynamicDescription.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dynamic_description }
    end
  end

  # GET /dynamic_descriptions/1/edit
  def edit
    @dynamic_description = DynamicDescription.find(params[:id])
  end

  # POST /dynamic_descriptions
  # POST /dynamic_descriptions.xml
  def create
    book = load_book
    if params[:dynamic_description] && params[:dynamic_image_id] 
      @dynamic_image = DynamicImage.where(:id => params[:dynamic_image_id]).first
      book = @dynamic_image.book if @dynamic_image
      @dynamic_description = @dynamic_image.dynamic_description  
        
      if @dynamic_description
          @dynamic_description.update_attributes({
            :body => params[:dynamic_description], 
            :book_id => book.id, 
            :submitter_id => current_user.id, 
            :summary => params[:summary],
            :simplified_language_description => params[:simplified_language_description],
            :target_age_start => params[:target_age_start],
            :target_age_end => params[:target_age_end],
            :target_grade_start => params[:target_grade_start],
            :target_grade_end => params[:target_grade_end],
            :annotation => params[:annotation],
            :tactile_src => params[:tactile_src],
            :tactile_tour => params[:tactile_tour]
          }) if params[:dynamic_description]
      else
          @dynamic_description = DynamicDescription.create({:body => params[:dynamic_description], :book_id => book.id, :submitter_id => current_user.id}) if params[:dynamic_description]
          @dynamic_image.dynamic_description =  @dynamic_description
      end       
    else
      @dynamic_description = DynamicDescription.new
      @dynamic_description.body = "missing parameters"
      @missing_parameters = true
    end
    
    respond_to do |format|
      if @missing_parameters
        format.html { render :action => "new" }
        format.xml  { render :xml => @dynamic_description, :status => :non_authoritative_information }
        format.json  { render :json => @dynamic_description, :callback => params[:callback], :status => :non_authoritative_information }
      elsif @dynamic_description.save
        @dynamic_description.reload
        format.html { render :partial => 'dynamic_images/show_history_fragment', :locals => {:descriptions => [@dynamic_description] }}
        format.html { redirect_to(@dynamic_description, :notice => 'Dynamic description was successfully created.') }
        format.xml  { render :xml => @dynamic_description, :status => :created, :location => @dynamic_description }
        format.json  { render :json => {:submitter => @dynamic_description.submitter_name}, :callback => params[:callback]}
      else
        @book_id = book.id
        @image_location = params[:image_location]
        format.html { render :action => "new" }
        format.xml  { render :xml => @dynamic_description.errors, :status => :non_authoritative_information }
        format.json  { render :json => @dynamic_description.errors.full_messages, :callback => params[:callback], :status => 400 }
      end
    end
  end


  # DELETE /dynamic_descriptions/1
  # DELETE /dynamic_descriptions/1.xml
  def destroy
    @dynamic_description = DynamicDescription.find(params[:id])
    @dynamic_description.destroy

    respond_to do |format|
      format.html { redirect_to(dynamic_descriptions_url) }
      format.xml  { head :ok }
    end
  end
  
  def delete_descriptions_by_id
    description_ids_to_delete = params[:ids]
    DynamicDescription.where(:id => description_ids_to_delete).delete_all if description_ids_to_delete.present?
    render :text => 'Descriptions deleted'
  end

  def search 
    @search_term = search_term = params['search']['term']
    @search_title = search_title = params['search']['title']
    @search_isbn = search_isbn = params['search']['isbn']
    @search_image = search_image = params['search']['image']
    @search_image_type = search_image_type = params['search']['image_type']
    @user_library_id = user_library_id =  current_user.user_libraries.first.library_id
    @search_submitter_by = search_submitter_by = params['search']['submitter_by']
    @search_authors = search_authors = params['search']['authors']
    

    @host =  @repository.get_host(request)
    @results = DynamicDescription.tire.search(:per_page => 20, :page => (params[:page] || 1)) do  
     query do
       boolean do
         must   { term :body, search_term } if search_term.present?
         must   { term :title, search_title } if search_title.present?
         must   { term :isbn, search_isbn } if search_isbn.present?
         must   { term :dynamic_image_id, search_image } if search_image.present?
         must   { term :authors, search_authors } if search_authors.present?         
         must   { term :image_type, search_image_type } if search_image_type.present?
         must   { term :submitter_by, search_submitter_by } if search_submitter_by.present?
         must   { term :is_last_approved, '1' }
         must   { term :is_not_deleted, '1'}
         must   { term :dynamic_description_library_id, user_library_id}
       end
     end
    end
    @dynamic_description_hash = DynamicDescription.where(:id => @results.map(&:id)).all.inject({}){|acc, desc| acc[desc.id] = desc; acc}
  end
  
  def body_history
    dynamic_image = DynamicImage.where(:id => params['image_id']).first
    @dynamic_description = dynamic_image.dynamic_description  
end


end

