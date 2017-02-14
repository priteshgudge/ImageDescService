class AddNoneImageCategory < ActiveRecord::Migration
  def self.up
    ImageCategory.reset_column_information
    ImageCategory.create :name => "None",  :sample_file_name => "image-categories/blank.html", :order_to_display => 0
  end

  def self.down
  end
end
