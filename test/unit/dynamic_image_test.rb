require 'test_helper'

class DynamicImageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "best_description should return the later record" do
    image = DynamicImage.new(:image_location => 'image location')
    old_description = "this is old"
    new_description = "this one is new"
    desc1 = DynamicDescription.new( {:dynamic_image_id => image.id, :body => old_description} )
    image.dynamic_description = desc1
    desc2 = DynamicDescription.new( {:dynamic_image_id => image.id, :body => new_description} )
    image.dynamic_description = desc2
    
    best = image.dynamic_description
    assert_equal desc2.id, best.id
    assert_equal new_description, best.body
  end
end
