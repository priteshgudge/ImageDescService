require 'spec_helper'

describe Alt do
  it "has a valid factory" do
    Factory.create(:alt).should be_valid
  end
  
  it "can be blank text"
  it "has a maximum length"
  it "is invalid without a dynamic image id"
end
