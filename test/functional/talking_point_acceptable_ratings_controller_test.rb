require 'test_helper'

class TalkingPointAcceptableRatingsControllerTest < ActionController::TestCase
  setup do
    @talking_point_acceptable_rating = talking_point_acceptable_ratings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:talking_point_acceptable_ratings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create talking_point_acceptable_rating" do
    assert_difference('TalkingPointAcceptableRating.count') do
      post :create, :talking_point_acceptable_rating => @talking_point_acceptable_rating.attributes
    end

    assert_redirected_to talking_point_acceptable_rating_path(assigns(:talking_point_acceptable_rating))
  end

  test "should show talking_point_acceptable_rating" do
    get :show, :id => @talking_point_acceptable_rating.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @talking_point_acceptable_rating.to_param
    assert_response :success
  end

  test "should update talking_point_acceptable_rating" do
    put :update, :id => @talking_point_acceptable_rating.to_param, :talking_point_acceptable_rating => @talking_point_acceptable_rating.attributes
    assert_redirected_to talking_point_acceptable_rating_path(assigns(:talking_point_acceptable_rating))
  end

  test "should destroy talking_point_acceptable_rating" do
    assert_difference('TalkingPointAcceptableRating.count', -1) do
      delete :destroy, :id => @talking_point_acceptable_rating.to_param
    end

    assert_redirected_to talking_point_acceptable_ratings_path
  end
end
