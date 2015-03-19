ActiveAdmin.register BookStats, :as => "Reports" do
  menu :if => proc{ can? :admin_user, @all }
  
  actions :index
  
  csv do
    column "Uid" do |book_stats|
       book_stats.book.uid
    end  
    column "Title" do |book_stats| 
       book_stats.book.title
    end
    column "Library" do |book_stats|
      Library.joins(:books).where(books: {:id => book_stats.book_id}).first.name
    end
    column :total_images
    column :total_essential_images
    column "% Essential" do |book_stats|
       number_to_percentage(book_stats.percent_essential, :precision => 1)
    end
    column :total_images_described
    column :essential_images_described
    column "% Essential Described"  do |book_stats|
      if (book_stats.total_essential_images == 0 || book_stats.total_images_described == 0)
        number_to_percentage(0, :precision => 1)
      else
        number_to_percentage(book_stats.percent_essential_described, :precision => 1)
     end
    end
    column :approved_descriptions
  end
  
  index do
    column "Uid" do |book_stats|
       link_to book_stats.book.uid, admin_books_path('q[uid_contains]' => book_stats.book.uid)
    end
    column "Title" do |book_stats| 
       link_to book_stats.book.title, edit_book_edit_path(:book_id => book_stats.book_id)
    end
    column "Library" do |book_stats|
      Library.joins(:books).where(books: {:id => book_stats.book_id}).first.name
    end
    column :total_images
    column :total_essential_images
    column "% Essential" do |book_stats|
       number_to_percentage(book_stats.percent_essential, :precision => 1)
    end
    column :total_images_described
    column :essential_images_described
    column "% Essential Described", :sortable => :percent_essential_described  do |book_stats|
      if (book_stats.total_essential_images == 0 || book_stats.total_images_described == 0)
        number_to_percentage(0, :precision => 1)
      else
        number_to_percentage(book_stats.percent_essential_described, :precision => 1)
     end
    end
    column :approved_descriptions
  end
  
  sidebar "Totals" do
    div do
      render 'image_totals'
    end
  end

  sidebar "Update" do
    div :class => :action do
      link_to "Update Book Stats", reports_update_book_stats_path(), :data => {:remote => true, :method => "get", :type => :text}, :class => "book-link-ajax"
    end
    div :class => :action do
      link_to "Describer Count Report", reports_describer_list_path(), :target => '_blank'
    end
  end

  filter :percent_essential_described
  filter :book_title, as: :string
  filter :book_uid, as: :string

end

