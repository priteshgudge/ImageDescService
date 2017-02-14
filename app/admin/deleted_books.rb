ActiveAdmin.register Book, :as => "DeletedBooks" do  
  menu :if => proc{ can? :admin_user, @all }
  scope_to :current_library, :association_method => :related_deleted_books
  
  actions :index

  index do
    column :id
    column  :uid
    column  :title 
    column "Library" do |book|
      Book.connection.select_value "select libraries.name from libraries where libraries.id = #{book.library_id}"  
    end
    column :isbn
    column "Status" do |book|
      book.status_to_english
    end
    column :description
    column :authors
    column "Format", :file_type
    column "Added", :created_at, :class =>'body'
    column  "Deleted at", :deleted_at
  
  
  end
  
  filter :uid 
  filter :title
  filter :isbn
  filter :authors
  filter :description
  
end