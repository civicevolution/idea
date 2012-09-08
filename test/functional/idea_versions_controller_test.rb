require 'test_helper'

class IdeaVersionsControllerTest < ActionController::TestCase
  setup do
    @idea_version = idea_versions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:idea_versions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create idea_version" do
    assert_difference('IdeaVersion.count') do
      post :create, idea_version: { idea_id: @idea_version.idea_id, lock_member_id: @idea_version.lock_member_id, member_id: @idea_version.member_id, text: @idea_version.text, version: @idea_version.version }
    end

    assert_redirected_to idea_version_path(assigns(:idea_version))
  end

  test "should show idea_version" do
    get :show, id: @idea_version
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @idea_version
    assert_response :success
  end

  test "should update idea_version" do
    put :update, id: @idea_version, idea_version: { idea_id: @idea_version.idea_id, lock_member_id: @idea_version.lock_member_id, member_id: @idea_version.member_id, text: @idea_version.text, version: @idea_version.version }
    assert_redirected_to idea_version_path(assigns(:idea_version))
  end

  test "should destroy idea_version" do
    assert_difference('IdeaVersion.count', -1) do
      delete :destroy, id: @idea_version
    end

    assert_redirected_to idea_versions_path
  end
end
