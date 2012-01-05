ActiveAdmin.register BookStats, :as => "Reports" do
  menu :if => proc{ can? :admin_user, @all }
  
  index do
    column "Uid", do |book_stats|
      link_to book_stats.book.uid, reports_view_book_path(:book_id => book_stats.book.id)
    end  
    column "Title" do |book_stats| 
       link_to  book_stats.book.title, edit_book_edit_path(:book_id => book_stats.book.id)  
    end
    column :total_images
    column :total_essential_images
    column "% Essential" do |book_stats|
       number_to_percentage(book_stats.total_essential_images * 100.00/book_stats.total_images, :precision => 1)
    end
    column :total_images_described
    column :essential_images_described
    column "% Essential Described"  do |book_stats|
      if (book_stats.total_essential_images == 0 || book_stats.total_images_described == 0)
        number_to_percentage(0, :precision => 1)
      else
        number_to_percentage(book_stats.essential_images_described * 100.00/book_stats.total_essential_images, :precision => 1)
     end
    end
  end
  
  sidebar "Totals" do
    div do
      render 'image_totals' 
    end
  end
  
  sidebar "Update" do
    div :class => :action do
      link_to "Update Book Stats", reports_update_book_stats_path( ), :remote => true, :method => "get", :format => :js, :class => "book-link-ajax"
    end
  end
  
  filter :book_title, as: :string
  filter :book_uid, as: :string
end
