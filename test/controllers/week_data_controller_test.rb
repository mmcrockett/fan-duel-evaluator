require 'test_helper'

class WeekDataControllerTest < ActionController::TestCase
  setup do
    @week_datum = week_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:week_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create week_datum" do
    assert_difference('WeekDatum.count') do
      post :create, week_datum: { dvoa: @week_datum.dvoa, fan_duel: @week_datum.fan_duel, fftoday: @week_datum.fftoday, week: @week_datum.week, yahoo: @week_datum.yahoo }
    end

    assert_redirected_to week_datum_path(assigns(:week_datum))
  end

  test "should show week_datum" do
    get :show, id: @week_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @week_datum
    assert_response :success
  end

  test "should update week_datum" do
    patch :update, id: @week_datum, week_datum: { dvoa: @week_datum.dvoa, fan_duel: @week_datum.fan_duel, fftoday: @week_datum.fftoday, week: @week_datum.week, yahoo: @week_datum.yahoo }
    assert_redirected_to week_datum_path(assigns(:week_datum))
  end

  test "should destroy week_datum" do
    assert_difference('WeekDatum.count', -1) do
      delete :destroy, id: @week_datum
    end

    assert_redirected_to week_data_path
  end
end
