class Alt < ActiveRecord::Base
  belongs_to :dynamic_image
  validates :alt, :length => { :minimum => 0, :maximum => 256, :allow_blank => true } 
  validates :dynamic_image_id, :presence => true
  belongs_to :submitter, :class_name => 'User', :foreign_key => :submitter_id
  accepts_nested_attributes_for :dynamic_image, :allow_destroy => true

  
end
