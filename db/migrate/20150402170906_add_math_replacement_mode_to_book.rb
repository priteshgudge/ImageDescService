class AddMathReplacementModeToBook < ActiveRecord::Migration
  def change
    add_column :books, :math_replacement_mode_id, :integer
    add_constraint 'books', 'books_math_replacement_mode_id', 'math_replacement_mode_id', 'math_replacement_modes', 'id'
  end
end
