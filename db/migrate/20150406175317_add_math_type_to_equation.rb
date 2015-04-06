class AddMathTypeToEquation < ActiveRecord::Migration
  def change
    add_column :equations, :math_type, :string
  end
end
