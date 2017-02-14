require 'spec_helper'

describe Alt do
  it "has a valid factory" do
    FactoryGirl.create(:alt).should be_valid
  end
  
  it "can be blank text" do
    FactoryGirl.create(:alt, alt: "").should be_valid
  end
  
  it "has a maximum length" do
    long_description = "Text that is longer than 255. Text that is longer than 255. Text that is longer than 255. Text that is longer than 255. Text that is longer than 255. Text that is longer than 255. Text that is longer than 255. Text that is longer than 255. Text that is longer than 255. "
    FactoryGirl.build(:alt, alt: long_description).should_not be_valid
  end
  
  it "is invalid without a dynamic image id" do
    FactoryGirl.build(:alt, dynamic_image: nil).should_not be_valid
  end
end
