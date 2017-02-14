class DropUniqueUsername < ActiveRecord::Migration
  def self.up
     remove_index(:users, :name=>'index_users_on_username')
     remove_index(:users, :name=>'index_users_on_email')
  end

  def self.down
  end
end
