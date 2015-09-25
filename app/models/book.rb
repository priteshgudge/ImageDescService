class Book < ActiveRecord::Base
  paginates_per 25

  validates :uid,  :presence => true, :length => { :maximum => 255 }
  validates :isbn, :length => { :maximum => 13 }
  
  has_many :dynamic_descriptions, :dependent => :destroy
  has_many :dynamic_images, :dependent => :destroy
  has_many :book_stats, :class_name => 'BookStats', :foreign_key => :book_id, :dependent => :destroy
  has_many :book_fragments, :dependent => :destroy
  belongs_to :library
  after_save :index_related_descriptions
  
  def index_related_descriptions
    if deleted_at
      dynamic_descriptions.each{|description| description.index.store description}
    end
  end
  
  def mark_approved

    # set the latest descriptions as current (approved)
    begin
      dynamic_descriptions.each do |dd|
        dd.is_current = 0
        dd.save # important:: force re-indexing in elastic search on each description
      end
      
      DynamicDescription.where(:id => Book.connection.select_values("select id from
         (select max(id) as id from dynamic_descriptions where book_id = '#{self.id}' group by dynamic_image_id) temptable")).each do |d_description|
         d_description.is_current = 1
         d_description.book_id = self.id
         d_description.date_approved = Time.now
         d_description.save  # important:: force re-indexing in elastic search on each description
      end
      # TODO ESH: may be able to AREL-ize this:
       Book.connection.execute("update dynamic_descriptions set is_current = 1, date_approved = now() where id in (select id from
         (select max(id) as id from dynamic_descriptions where book_id = '#{self.id}' group by dynamic_image_id) temptable)")
    rescue Exception => e
      puts e.message
      logger.info "#{e.class}: #{e.message}"
    end

    # set approved flag at the book level
    update_attribute("last_approved", Time.now)

    # update the stats for this book
    BookStats.create_book_row(self)
  end

  def current_images_and_descriptions
    dynamic_images.includes(:dynamic_description).where(:dynamic_descriptions => {:is_current => true}).group('dynamic_descriptions.id')
  end
    
  def book_stats_plus_unessential_images_described
    book_stats.select("book_stats.*, total_images_described - essential_images_described as unessential_images_described") 
  end

  def dynamic_desc_submitters
    User.where( :id => dynamic_descriptions.map(&:submitter_id), :deleted_at => nil).select(:email).map(&:email)
  end
  
  def status_to_english
    case status
      when 0
        'Expired'
      when 1
        'Processing Images'
      when 2
        'Processing Book'
      when 3
        'Ready'
      when 4
        'Preprocessing Book'  
      when 5
        'Failed'
      else
        'Processing'
    end
  end

end