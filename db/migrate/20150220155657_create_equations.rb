class CreateEquations < ActiveRecord::Migration
  def up
    create_table :equations do |t|
      t.timestamps
      t.string :element, :null => false
      t.integer :submitter_id
      t.integer :dynamic_image_id
      t.string :described_at
    end
    add_constraint 'equations', 'equations_submitter_id', 'submitter_id', 'users', 'id'
    add_constraint 'equations', 'equations_dynamic_image_id', 'dynamic_image_id', 'dynamic_images', 'id'
  end

  def self.down
    drop_table :equations
  end
end
