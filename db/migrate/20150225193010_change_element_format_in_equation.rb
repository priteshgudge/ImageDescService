class ChangeElementFormatInEquation < ActiveRecord::Migration
  def up
    change_column :equations, :element, :text
  end
end
