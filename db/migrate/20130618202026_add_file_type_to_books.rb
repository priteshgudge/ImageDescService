class AddFileTypeToBooks < ActiveRecord::Migration
  def self.up
     add_column :books, :file_type, :string
  end

  def self.down
    remove_column :books, :file_type
  end
end
