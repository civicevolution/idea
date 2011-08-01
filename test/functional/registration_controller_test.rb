require 'test_helper'

class RegistrationControllerTest < ActionController::TestCase
  test "should get register" do
    get :register
    assert_response :success
  end

  test "should get request_confirmation_email" do
    get :request_confirmation_email
    assert_response :success
  end

  test "should get confirm_registration" do
    get :confirm_registration
    assert_response :success
  end

end
