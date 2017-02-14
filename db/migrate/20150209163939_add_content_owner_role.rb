class AddContentOwnerRole < ActiveRecord::Migration
  def up
    ["Content Owner"].each {|name|  Role.create(:name => name) unless Role.exists?(:name => name)}  
  end

  def down
  end
end
