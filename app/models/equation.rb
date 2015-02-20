class Equation < ActiveRecord::Base
  belongs_to :dynamic_image
  validates :element, :length => { :minimum => 0, :allow_blank => false } 
  validates :dynamic_image_id, :presence => true
  belongs_to :submitter, :class_name => 'User', :foreign_key => :submitter_id
  accepts_nested_attributes_for :dynamic_image, :allow_destroy => true  
end
