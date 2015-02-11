class AddAlts < ActiveRecord::Migration
  def up
    create_table :alts do |t|
      t.timestamps
      t.string :alt, :null => false
      t.integer :submitter_id
      t.integer :dynamic_image_id
      t.boolean :is_current , :default => false, :null => false
    end
    add_constraint 'alts', 'alts_submitter_id', 'submitter_id', 'users', 'id'
    add_constraint 'alts', 'alts_dynamic_image_id', 'dynamic_image_id', 'dynamic_images', 'id'
  end

  def self.down
    drop_table :alts
  end
end
