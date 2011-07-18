require 'test_helper'

class AnswerDiffsControllerTest < ActionController::TestCase
  setup do
    @answer_diff = answer_diffs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:answer_diffs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create answer_diff" do
    assert_difference('AnswerDiff.count') do
      post :create, :answer_diff => @answer_diff.attributes
    end

    assert_redirected_to answer_diff_path(assigns(:answer_diff))
  end

  test "should show answer_diff" do
    get :show, :id => @answer_diff.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @answer_diff.to_param
    assert_response :success
  end

  test "should update answer_diff" do
    put :update, :id => @answer_diff.to_param, :answer_diff => @answer_diff.attributes
    assert_redirected_to answer_diff_path(assigns(:answer_diff))
  end

  test "should destroy answer_diff" do
    assert_difference('AnswerDiff.count', -1) do
      delete :destroy, :id => @answer_diff.to_param
    end

    assert_redirected_to answer_diffs_path
  end
end
