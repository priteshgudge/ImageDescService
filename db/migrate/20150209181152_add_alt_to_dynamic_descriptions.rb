class AddAltToDynamicDescriptions < ActiveRecord::Migration
  def self.up
    add_column :dynamic_descriptions, :alt, :string
  end

  def self.down
    remove_column :dynamic_descriptions, :alt
  end
end
