require 'test_helper'

class DynamicImagesControllerTest < ActionController::TestCase
  setup do
    @dynamic_image = dynamic_images(:one)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dynamic_image" do
    assert_difference('DynamicImage.count') do
      post :create, :dynamic_image => @dynamic_image.attributes
    end

    assert_redirected_to dynamic_image_path(assigns(:dynamic_image))
  end

  test "should get show" do
    get :show, :id => @dynamic_image.to_param
    assert_response :success
  end

end
