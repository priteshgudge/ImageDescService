class BookStats < ActiveRecord::Base
  belongs_to :book

  def percent_essential
    self.total_essential_images * 100.00 / self.total_images
  end

  def percent_essential_described
    self.essential_images_described * 100.00/self.total_essential_images
  end

  def self.create_book_row (book)
    book_stats = BookStats.where(:book_id => book.id).first

    if !(book_stats)
      book_stats = BookStats.new :book_id => book.id
    end
    book_stats.total_images = DynamicDescription.connection.select_value("select count(id) from dynamic_images where book_id = '#{book.id}'")
    book_stats.total_essential_images = DynamicImage.connection.select_value("select count(id) from dynamic_images where book_id = '#{book.id}' and should_be_described = 1")
    book_stats.total_images_described = DynamicDescription.connection.select_value("select count(distinct(dynamic_image_id)) from dynamic_descriptions where book_id = '#{book.id}'")
    book_stats.essential_images_described = DynamicDescription.connection.select_value("SELECT count(distinct(id)) FROM dynamic_images di,
    (select dynamic_image_id from dynamic_descriptions where dynamic_descriptions.book_id = '#{book.id}') as essential
    WHERE book_id = '#{book.id}' and should_be_described = 1 and di.id = essential.dynamic_image_id ;")
    book_stats.approved_descriptions = DynamicDescription.connection.select_value("SELECT count(id) from dynamic_descriptions where is_current = 1 and book_id = '#{book.id}'")
    book_stats.percent_essential_described = book_stats.essential_images_described * 100.00/book_stats.total_essential_images
    book_stats.save!
  end
end