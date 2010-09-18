require 'test_helper'

class InitiativesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:initiatives)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create initiative" do
    assert_difference('Initiative.count') do
      post :create, :initiative => { }
    end

    assert_redirected_to initiative_path(assigns(:initiative))
  end

  test "should show initiative" do
    get :show, :id => initiatives(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => initiatives(:one).to_param
    assert_response :success
  end

  test "should update initiative" do
    put :update, :id => initiatives(:one).to_param, :initiative => { }
    assert_redirected_to initiative_path(assigns(:initiative))
  end

  test "should destroy initiative" do
    assert_difference('Initiative.count', -1) do
      delete :destroy, :id => initiatives(:one).to_param
    end

    assert_redirected_to initiatives_path
  end
end
