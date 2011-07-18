require 'test_helper'

class TalkingPointPreferencesControllerTest < ActionController::TestCase
  setup do
    @talking_point_preference = talking_point_preferences(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:talking_point_preferences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create talking_point_preference" do
    assert_difference('TalkingPointPreference.count') do
      post :create, :talking_point_preference => @talking_point_preference.attributes
    end

    assert_redirected_to talking_point_preference_path(assigns(:talking_point_preference))
  end

  test "should show talking_point_preference" do
    get :show, :id => @talking_point_preference.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @talking_point_preference.to_param
    assert_response :success
  end

  test "should update talking_point_preference" do
    put :update, :id => @talking_point_preference.to_param, :talking_point_preference => @talking_point_preference.attributes
    assert_redirected_to talking_point_preference_path(assigns(:talking_point_preference))
  end

  test "should destroy talking_point_preference" do
    assert_difference('TalkingPointPreference.count', -1) do
      delete :destroy, :id => @talking_point_preference.to_param
    end

    assert_redirected_to talking_point_preferences_path
  end
end
