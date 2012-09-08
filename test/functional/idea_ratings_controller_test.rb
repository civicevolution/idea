require 'test_helper'

class IdeaRatingsControllerTest < ActionController::TestCase
  setup do
    @idea_rating = idea_ratings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:idea_ratings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create idea_rating" do
    assert_difference('IdeaRating.count') do
      post :create, idea_rating: { idea_id: @idea_rating.idea_id, member_id: @idea_rating.member_id, rating: @idea_rating.rating }
    end

    assert_redirected_to idea_rating_path(assigns(:idea_rating))
  end

  test "should show idea_rating" do
    get :show, id: @idea_rating
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @idea_rating
    assert_response :success
  end

  test "should update idea_rating" do
    put :update, id: @idea_rating, idea_rating: { idea_id: @idea_rating.idea_id, member_id: @idea_rating.member_id, rating: @idea_rating.rating }
    assert_redirected_to idea_rating_path(assigns(:idea_rating))
  end

  test "should destroy idea_rating" do
    assert_difference('IdeaRating.count', -1) do
      delete :destroy, id: @idea_rating
    end

    assert_redirected_to idea_ratings_path
  end
end
