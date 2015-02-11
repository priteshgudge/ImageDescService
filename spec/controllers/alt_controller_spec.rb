require 'spec_helper'

describe AltController do

  describe "GET 'create,'" do
    it "returns http success" do
      get 'create,'
      response.should be_success
    end
  end

  describe "GET 'get'" do
    it "returns http success" do
      get 'get'
      response.should be_success
    end
  end

end
