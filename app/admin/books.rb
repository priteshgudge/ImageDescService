ActiveAdmin.register Book do
  scope_to :current_library, :association_method => :related_books
  menu :priority => 1
  
  actions :index

  index do
    column :id
    column  :uid do |book|
      link_to book.uid, admin_reports_path('q[book_uid_contains]' => book.uid)
      end
    column  :title do |book|
      unless book.status == 3 then
        book.title
      else
        link_to book.title, edit_book_edit_path(:book_id => book.id)
      end
    end
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
    
    if can? :tag_all_images, @all
    column  do |book| 
      div :class => :action do
        link_to "Mark All Essential", imageDesc_mark_all_essential_path(:book_id => book.id), :remote => true, :method => "post", :format => :js, :class => "book-link-ajax"
      end
    end
    end 
    column  do |book| 
      div :class => :action do
        link_to "Approve Image Description", books_mark_approved_path(:book_id => book.id), :remote => true, :method => "post", :format => :js, :class => "book-link-ajax"
      end
    end
    column  do |book| 
      div :class => :action do
        link_to "Delete", admin_book_delete_path(:book_id => book.id), :confirm=>'Are you sure?'
      end
    end
  end
  
  filter :uid 
  filter :title
  filter :isbn
  filter :authors
  filter :description
  
end
