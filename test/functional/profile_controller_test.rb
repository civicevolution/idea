require 'test_helper'

class ProfileControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get upload_photo" do
    get :upload_photo
    assert_response :success
  end

  test "should get my_teams" do
    get :my_teams
    assert_response :success
  end

end
