require 'test_helper'

class TalkingPointsControllerTest < ActionController::TestCase
  setup do
    @talking_point = talking_points(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:talking_points)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create talking_point" do
    assert_difference('TalkingPoint.count') do
      post :create, :talking_point => @talking_point.attributes
    end

    assert_redirected_to talking_point_path(assigns(:talking_point))
  end

  test "should show talking_point" do
    get :show, :id => @talking_point.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @talking_point.to_param
    assert_response :success
  end

  test "should update talking_point" do
    put :update, :id => @talking_point.to_param, :talking_point => @talking_point.attributes
    assert_redirected_to talking_point_path(assigns(:talking_point))
  end

  test "should destroy talking_point" do
    assert_difference('TalkingPoint.count', -1) do
      delete :destroy, :id => @talking_point.to_param
    end

    assert_redirected_to talking_points_path
  end
end
