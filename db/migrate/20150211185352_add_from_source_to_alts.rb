class AddFromSourceToAlts < ActiveRecord::Migration
  def change
    add_column :alts, :from_source, :boolean, :default => false
  end
end
