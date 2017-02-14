class AddDeletedAtFlag < ActiveRecord::Migration
  def self.up
      add_column :books, :deleted_at, :datetime
      add_column :users, :deleted_at, :datetime  
  end

  def self.down
  end
end
