require 'test_helper'

class TalkingPointVersionsControllerTest < ActionController::TestCase
  setup do
    @talking_point_version = talking_point_versions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:talking_point_versions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create talking_point_version" do
    assert_difference('TalkingPointVersion.count') do
      post :create, :talking_point_version => @talking_point_version.attributes
    end

    assert_redirected_to talking_point_version_path(assigns(:talking_point_version))
  end

  test "should show talking_point_version" do
    get :show, :id => @talking_point_version.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @talking_point_version.to_param
    assert_response :success
  end

  test "should update talking_point_version" do
    put :update, :id => @talking_point_version.to_param, :talking_point_version => @talking_point_version.attributes
    assert_redirected_to talking_point_version_path(assigns(:talking_point_version))
  end

  test "should destroy talking_point_version" do
    assert_difference('TalkingPointVersion.count', -1) do
      delete :destroy, :id => @talking_point_version.to_param
    end

    assert_redirected_to talking_point_versions_path
  end
end
