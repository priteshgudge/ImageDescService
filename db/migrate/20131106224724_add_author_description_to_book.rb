class AddAuthorDescriptionToBook < ActiveRecord::Migration
  def self.up
     add_column :books, :authors, :string
     add_column :books, :description, :string     
  end

  def self.down
    remove_column :books, :authors
    remove_column :books, :description
  end
end
