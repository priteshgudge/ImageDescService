class Library < ActiveRecord::Base
  validates :name,  :presence => true ,
                    :length => { :maximum => 128 }

  has_many :books, :dependent => :destroy
  has_many :images
  has_many :user_libraries, :dependent => :destroy
  has_many :users, :through => :user_libraries, :dependent => :destroy
  
  def related_books
    Book.where(:library_id => self.id, :deleted_at => nil).readonly(false)
  end
  
  def related_books_by_description  
      Book.select("books.*, submitter_dynamic_descriptions.submitter_id").joins("left outer join dynamic_descriptions submitter_dynamic_descriptions on submitter_dynamic_descriptions.book_id = books.id").where(:library_id => self.id,  :deleted_at => nil).group("books.id, submitter_dynamic_descriptions.submitter_id").readonly(false)        
  end
  
  def related_users
    # User.joins(:user_libraries).where('user_libraries.library_id' => self.id).readonly(false)
     User.where(:deleted_at => nil).readonly(false)
  end
  
  def related_book_stats
     BookStats.joins(:book => :library).where(:libraries => {:id => self.id}).where('books.deleted_at is null').readonly(false)  
  end  
  
  def related_deleted_books
      Book.where(:library_id => self.id).where("deleted_at is not null").readonly(false)
  end
  
  def related_deleted_users
      User.where("deleted_at is not null").readonly(false)
  end
end
