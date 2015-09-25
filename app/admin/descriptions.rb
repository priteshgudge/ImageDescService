ActiveAdmin.register Book, :as => "BookDescriptions" do  
  menu :if => proc{ can? :admin_user, @all }
  
   actions :index
   index do
      
      column  :uid 
      column  :title 
      column  :library
      
      column "Total Images" do |book|
         num_images = Book.connection.select_value "select count(*) from dynamic_images di where di.book_id = #{book.id}"  
         num_images.to_s
      end  

      column "Approved Descriptions" do |book|
        DynamicDescription.where(:book_id => book.id).where('date_approved is not null').count.to_s
      end
      
      column "Described by" do |book|
          described_by = Book.connection.select_value "select email from users where id = #{book.user_id} and deleted_at is null" if book.user_id
          if described_by == nil then "Unknown" else described_by.to_s end
      end
      
      column "# Images Described" do |book|
        DynamicDescription.where(:book_id => book.id).count.to_s
      end
      
      column "Edit Descriptions" do |book|
        unapproved_description_ids = DynamicDescription.where(:book_id => book.id, :date_approved => nil).select(:id).map(&:id)
        if unapproved_description_ids.blank?
          "No unapproved images"
        else
           div :class => :action do
             link_to "Delete Unapproved Descriptions", delete_descriptions_by_id_path(:ids => unapproved_description_ids), :data => {:remote => true, :method => "post", :type => :text}, :class => "delete-descriptions-link-ajax"
          end
        end
      end
    end
    
    filter :book_stats_percent_essential_described, :as => :numeric
    filter :title, as: :string, :label => 'Book Title'
    filter :uid, as: :string, :label => 'Book UID' 
    filter :dynamic_descriptions_submitter_email, :as => :select, :collection => proc {User.all.map(&:email)}, :label => "Image Describer Email"

end  