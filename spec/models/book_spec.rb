require 'spec_helper'

describe Book do
  it "has a valid factory" do
    FactoryGirl.create(:book).should be_valid
  end
  
  it "can have empty title" do
    FactoryGirl.create(:book, title: "").should be_valid
  end
  
  it "must have a UID" do
    FactoryGirl.build(:book, uid: nil).should_not be_valid
  end
  
  it "validates ISBN length" do
    FactoryGirl.build(:book, isbn: "12345678901234").should_not be_valid
  end
  
  it "converts status to text" do
    FactoryGirl.build(:book, status: 3).status_to_english.should eq "Ready"
  end
  
  xit "creates book statistics when approved" do
    book = FactoryGirl.create(:book)
    image = FactoryGirl.create(:dynamic_image, book: book)
    description = FactoryGirl.create(:dynamic_description, dynamic_image: image)
    book.images.add image
    book.dynamic_descriptions.add description
    
    book.mark_approved
    
    BookStats.where(:book_id => book.id).should exist
  end
  
  it "returns only current image descriptions"
  
  it "returns submitters of current image descriptions"
end
