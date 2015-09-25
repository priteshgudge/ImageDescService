class AddSourceToEquation < ActiveRecord::Migration
  def change
    add_column :equations, :source, :text
  end
end
