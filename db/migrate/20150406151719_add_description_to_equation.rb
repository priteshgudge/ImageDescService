class AddDescriptionToEquation < ActiveRecord::Migration
  def change
    add_column :equations, :description, :text
  end
end
