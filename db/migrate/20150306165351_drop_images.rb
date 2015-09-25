class DropImages < ActiveRecord::Migration
  def up
    drop_table :images
  end
end
