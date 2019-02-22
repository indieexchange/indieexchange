require 'test_helper'

class PrivateMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @private_message = private_messages(:one)
  end

  test "should get index" do
    get private_messages_url
    assert_response :success
  end

  test "should get new" do
    get new_private_message_url
    assert_response :success
  end

  test "should create private_message" do
    assert_difference('PrivateMessage.count') do
      post private_messages_url, params: { private_message: { last_message_time: @private_message.last_message_time, post_id: @private_message.post_id, user_a_id: @private_message.user_a_id, user_b_id: @private_message.user_b_id } }
    end

    assert_redirected_to private_message_url(PrivateMessage.last)
  end

  test "should show private_message" do
    get private_message_url(@private_message)
    assert_response :success
  end

  test "should get edit" do
    get edit_private_message_url(@private_message)
    assert_response :success
  end

  test "should update private_message" do
    patch private_message_url(@private_message), params: { private_message: { last_message_time: @private_message.last_message_time, post_id: @private_message.post_id, user_a_id: @private_message.user_a_id, user_b_id: @private_message.user_b_id } }
    assert_redirected_to private_message_url(@private_message)
  end

  test "should destroy private_message" do
    assert_difference('PrivateMessage.count', -1) do
      delete private_message_url(@private_message)
    end

    assert_redirected_to private_messages_url
  end
end
