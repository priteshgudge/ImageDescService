class DropUniqueUidBooks < ActiveRecord::Migration
  def self.up
    remove_index(:books, :name=>'index_books_on_uid')
  end

  def self.down
  end
end
