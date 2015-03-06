class DropDescriptions < ActiveRecord::Migration
  def up
    drop_table :descriptions
  end
end
