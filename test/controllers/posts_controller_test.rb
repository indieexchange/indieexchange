require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    assert_difference('Post.count') do
      post posts_url, params: { post: { description: @post.description, is_offering: @post.is_offering, is_promoted: @post.is_promoted, is_visible: @post.is_visible, last_update_bump_at: @post.last_update_bump_at, price: @post.price, rating: @post.rating, subcategory_id: @post.subcategory_id, title: @post.title } }
    end

    assert_redirected_to post_url(Post.last)
  end

  test "should show post" do
    get post_url(@post)
    assert_response :success
  end

  test "should get edit" do
    get edit_post_url(@post)
    assert_response :success
  end

  test "should update post" do
    patch post_url(@post), params: { post: { description: @post.description, is_offering: @post.is_offering, is_promoted: @post.is_promoted, is_visible: @post.is_visible, last_update_bump_at: @post.last_update_bump_at, price: @post.price, rating: @post.rating, subcategory_id: @post.subcategory_id, title: @post.title } }
    assert_redirected_to post_url(@post)
  end

  test "should destroy post" do
    assert_difference('Post.count', -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end
end
