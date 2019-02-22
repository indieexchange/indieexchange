require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
  end

  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end

  test "creating a Post" do
    visit posts_url
    click_on "New Post"

    fill_in "Description", with: @post.description
    fill_in "Is offering", with: @post.is_offering
    fill_in "Is promoted", with: @post.is_promoted
    fill_in "Is visible", with: @post.is_visible
    fill_in "Last update bump at", with: @post.last_update_bump_at
    fill_in "Price", with: @post.price
    fill_in "Rating", with: @post.rating
    fill_in "Subcategory", with: @post.subcategory_id
    fill_in "Title", with: @post.title
    click_on "Create Post"

    assert_text "Post was successfully created"
    click_on "Back"
  end

  test "updating a Post" do
    visit posts_url
    click_on "Edit", match: :first

    fill_in "Description", with: @post.description
    fill_in "Is offering", with: @post.is_offering
    fill_in "Is promoted", with: @post.is_promoted
    fill_in "Is visible", with: @post.is_visible
    fill_in "Last update bump at", with: @post.last_update_bump_at
    fill_in "Price", with: @post.price
    fill_in "Rating", with: @post.rating
    fill_in "Subcategory", with: @post.subcategory_id
    fill_in "Title", with: @post.title
    click_on "Update Post"

    assert_text "Post was successfully updated"
    click_on "Back"
  end

  test "destroying a Post" do
    visit posts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Post was successfully destroyed"
  end
end
