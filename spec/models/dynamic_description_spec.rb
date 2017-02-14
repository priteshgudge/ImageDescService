require 'spec_helper'

describe DynamicDescription do
  it "has a valid factory" do
    FactoryGirl.create(:dynamic_description).should be_valid
  end
  
  it "allows a blank description" do
    FactoryGirl.create(:dynamic_description, body: "").should be_valid
  end
  
  it "is invalid without an image" do
    FactoryGirl.build(:dynamic_description, dynamic_image: nil).should_not be_valid
  end
  
  it "removes body tag when saved" do
    body = "&lt;body&gt;Description text&lt;/body&gt;"
    description = FactoryGirl.create(:dynamic_description, body: body)
    
    description.body.should eq "Description text"
  end
  
  it "uses full name for submitter if available" do
    user = FactoryGirl.create(:user, first_name: "Unit", last_name: "Test")
    description = FactoryGirl.create(:dynamic_description, submitter: user)
    
    description.submitter_name.should eq "Unit Test"
  end
  
  # XXX User constraints don't allow first or last name to be blank, so this can't happen
  xit "uses username for submitter if full name is missing" do
    user = FactoryGirl.create(:user, first_name: "", last_name: "", username: "Tester")
    description = FactoryGirl.create(:dynamic_description, submitter: user)
    
    description.submitter_name.should eq "Tester"
  end

  # XXX User contraints don't allow username to be blank, so this can't happen
  xit "uses email for submitter if other names are missing" do
    user = FactoryGirl.create(:user, first_name: "", last_name: "", username: "", email: "unit@test.com")
    description = FactoryGirl.create(:dynamic_description, submitter: user)
    
    description.submitter_name.should eq "unit@test.com"
  end
  
  it "has a description history" do
    description = FactoryGirl.create(:dynamic_description)
    description.body = "Updated description"
    description.save
    
    description.description_history.length.should eq 2
  end
end
