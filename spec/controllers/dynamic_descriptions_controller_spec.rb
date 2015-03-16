require 'spec_helper'

describe DynamicDescriptionsController do

  before (:each) do
    #@user = FactoryGirl(:user)
    #sign_in @user
  end

  describe "should get new" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end
  
  describe "should get index" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
  
  describe 'should create new description' do
    it "should be successful" do
      post 'create', :dynamic_description => {:body => 'new description', :book_id => 1, :image_location => 'img03.jpg'}
      DynamicImage.count.should eq(2)
      response.should be_success
    end
  end

  describe "missing parameters on json create" do
    it "should be successful" do
      post 'create', :dynamic_description => {:body => 'new description'}, :format => 'json'
      assert_response :non_authoritative_information
    end
  end

end