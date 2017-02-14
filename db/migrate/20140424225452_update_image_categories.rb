class UpdateImageCategories < ActiveRecord::Migration

  @@new_categories = ["Geographic Map", "Artwork", "Photograph"]

  def up
  	# create new categories
  	@@new_categories.each do |n|
  		ImageCategory.create :name => n, :sample_file_name => "image-categories/blank.html"
  	end

  	# fetch all the image categories except for None, sorted alphabetically
  	categories = ImageCategory.where("name != 'None'").order(:name)
  	idx = 1
  	categories.each do |c|
  		c.order_to_display = idx
  		c.save
  		idx = idx + 1
	end
  end

  def down
  	@@new_categories.each do |n|
  		ImageCategory.where("name = ?", n).destroy_all
	end
  end
end
