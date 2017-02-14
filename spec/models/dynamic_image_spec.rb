require 'spec_helper'

describe DynamicImage do
  it "has a valid factory" do
    FactoryGirl.create(:dynamic_image).should be_valid
  end
  
  it "is invalid without a book" do
    FactoryGirl.build(:dynamic_image, book: nil).should_not be_valid
  end
  
  it "is invalid without an image location" do
    FactoryGirl.build(:dynamic_image, image_location: nil).should_not be_valid
  end
  
  it "has a current alt text" do
    image = FactoryGirl.create(:dynamic_image)
    alt1 = FactoryGirl.create(:alt, dynamic_image: image)
    alt2 = FactoryGirl.create(:alt, dynamic_image: image)
    
    image.current_alt.id.should eq alt2.id
  end
  
  it "has a current equation" do
    image = FactoryGirl.create(:dynamic_image)
    equation1 = FactoryGirl.create(:equation, dynamic_image: image)
    equation2 = FactoryGirl.create(:equation, dynamic_image: image)
    
    image.current_equation.id.should eq equation2.id
  end
end
