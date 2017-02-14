class CreateMathReplacementMode < ActiveRecord::Migration
  def up
    create_table :math_replacement_modes do |t|
      t.string :mode , :limit => 128, :null => false
      t.timestamps
    end
  end

  def down
    drop_table math_replacement_mode
  end
end
