require 'test_helper'

class IdeasControllerTest < ActionController::TestCase
  setup do
    @idea = ideas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ideas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create idea" do
    assert_difference('Idea.count') do
      post :create, idea: { is_theme: @idea.is_theme, member_id: @idea.member_id, order_id: @idea.order_id, parent_id: @idea.parent_id, question_id: @idea.question_id, team_id: @idea.team_id, text: @idea.text, version: @idea.version, visible: @idea.visible }
    end

    assert_redirected_to idea_path(assigns(:idea))
  end

  test "should show idea" do
    get :show, id: @idea
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @idea
    assert_response :success
  end

  test "should update idea" do
    put :update, id: @idea, idea: { is_theme: @idea.is_theme, member_id: @idea.member_id, order_id: @idea.order_id, parent_id: @idea.parent_id, question_id: @idea.question_id, team_id: @idea.team_id, text: @idea.text, version: @idea.version, visible: @idea.visible }
    assert_redirected_to idea_path(assigns(:idea))
  end

  test "should destroy idea" do
    assert_difference('Idea.count', -1) do
      delete :destroy, id: @idea
    end

    assert_redirected_to ideas_path
  end
end
