20.times do |i|
  u = User.new
  u.first_name = Faker::Name.first_name
  u.last_name = Faker::Name.last_name
  u.email = "testuser#{i + 1}@example.com"
  u.password = "passwordpassword"
  u.password_confirmation = "passwordpassword"
  u.is_trial_period = true
  u.trial_until = Time.new(2022, 1, 1)
  u.about_me = Faker::Lorem.paragraph_by_chars(number: 200) + "\r\n\r\n" + Faker::Lorem.paragraph_by_chars(number: 200)
  u.skip_confirmation!
  u.email_for_all_notifications = false
  u.save!
end

Category.create!(title: "Writing")
Category.create!(title: "Design")
Category.create!(title: "Editing")
Category.create!(title: "Promotional")
Category.create!(title: "Miscellaneous")

Subcategory.create!(category: Category.find_by_title("Writing"),       title: "Ghostwriting",         pricing_type: "word")
Subcategory.create!(category: Category.find_by_title("Writing"),       title: "Blurb",                pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Writing"),       title: "Plots",                pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Design"),        title: "Cover Art",            pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Design"),        title: "Promotional Graphic",  pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Design"),        title: "Website",              pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Editing"),       title: "Beta Reading",         pricing_type: "word")
Subcategory.create!(category: Category.find_by_title("Editing"),       title: "Proofreading",         pricing_type: "word")
Subcategory.create!(category: Category.find_by_title("Editing"),       title: "Copyediting",          pricing_type: "word")
Subcategory.create!(category: Category.find_by_title("Editing"),       title: "Development",          pricing_type: "word")
Subcategory.create!(category: Category.find_by_title("Editing"),       title: "Line editing",         pricing_type: "word")
Subcategory.create!(category: Category.find_by_title("Promotional"),   title: "Newsletter",           pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Promotional"),   title: "Advertising",          pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Promotional"),   title: "Advanced Reader Copy", pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Promotional"),   title: "Data Services",        pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Promotional"),   title: "Video Services",       pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Miscellaneous"), title: "Virtual Assistant",    pricing_type: "hour")
Subcategory.create!(category: Category.find_by_title("Miscellaneous"), title: "Formatting",           pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Miscellaneous"), title: "Audiobook Narration",  pricing_type: "booking")
Subcategory.create!(category: Category.find_by_title("Miscellaneous"), title: "Other",                pricing_type: "booking")

price_range = (10..200).to_a

User.all.each do |user|
  [1, 2, 3].sample.times do |post_number|
    post = Post.new
    post.user = user
    post.title = Faker::Lorem.sentence(word_count: [3, 4, 5, 6].sample).delete_suffix(".")
    post.description = Faker::Lorem.paragraph_by_chars(number: 350) + "\r\n\r\n" + Faker::Lorem.paragraph_by_chars(number: 350)
    post.price = price_range.sample
    post.category = Category.all.sample
    post.subcategory = post.category.subcategories.sample
    post.is_offering = [true, false].sample
    if Random.rand > 0.75
      post.news = "Exciting update about this listing: #{Faker::Lorem.sentence(word_count: [10, 12, 14].sample)}"
    end
    post.is_published = true
    post.external_website_link = "www.example.com"
    post.last_update_bump_at = Time.now
    post.save!
  end
end

3.times do
  User.all.each do |user|
    user_id = user.id
    other_user_id = (User.all.pluck(:id) - [user_id]).sample
    lower_id = [user_id, other_user_id].min
    higher_id = [user_id, other_user_id].max
    pm = PrivateMessage.where(user_a_id: lower_id, user_b_id: higher_id)
    if !pm.any?
      pm = PrivateMessage.new
      pm.user_a_id = lower_id
      pm.user_b_id = higher_id
      pm.save!
      10.times do |message_count|
        m = Message.new
        m.sender_id = [lower_id, higher_id].sample
        m.recipient_id = ([lower_id, higher_id] - [m.sender_id])[0]
        m.body = Faker::Lorem.sentence(word_count: [10, 12, 14, 16].sample).delete_suffix(".") + ["?", "!", "."].sample
        m.private_message = pm
        m.save!
      end
    end
  end
end

PrivateMessage.all.each do |pm|
  user_ids = [pm.user_a_id, pm.user_b_id]
  user_ids_random = user_ids.sample(2)
  upr = UserPostReview.new
  upr.reviewing_user_id = user_ids_random[0]
  upr.target_user_id = user_ids_random[1]
  upr.post = upr.target_user.posts.sample
  upr.title = Faker::Lorem.sentence(word_count: [4, 5, 6].sample).delete_suffix(".")
  upr.body = Faker::Lorem.paragraph_by_chars(number: 350) + "\r\n\r\n" + Faker::Lorem.paragraph_by_chars(number: 350)
  upr.score = [1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5].sample
  if upr.reviewing_user.can_review?(upr.post)
    upr.save!
  end

  uur = UserUserReview.new
  uur.reviewing_user_id = user_ids_random[0]
  uur.target_user_id = user_ids_random[1]
  uur.title = Faker::Lorem.sentence(word_count: [4, 5, 6].sample).delete_suffix(".")
  uur.body = Faker::Lorem.paragraph_by_chars(number: 350) + "\r\n\r\n" + Faker::Lorem.paragraph_by_chars(number: 350)
  uur.score = [1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5].sample
  if uur.reviewing_user.can_review_user?(uur.target_user)
    uur.save!
  end
end

User.all.each do |user|
  user_id = user.id
  people_to_follow = (User.all.pluck(:id) - [user_id]).sample([1, 2, 3, 4].sample)
  people_to_follow.each do |other_id|
    uuf = UserUserFollow.new
    uuf.follower_id = user_id
    uuf.target_id = other_id
    uuf.save!
  end
end

Post.all.each do |post|
  post_author_id = post.user.id
  commenter_id = (User.all.pluck(:id) - [post_author_id]).sample
  pc = PostComment.new
  pc.author_id = commenter_id
  pc.target_id = post_author_id
  pc.post_id = post.id
  pc.body = Faker::Lorem.paragraph_by_chars(number: 350) + "\r\n\r\n" + Faker::Lorem.paragraph_by_chars(number: 350)
  pc.save!
  pcr = PostCommentReply.new
  pcr.post = post
  pcr.target = post.user
  pcr.author_id = (User.all.pluck(:id) - [post_author_id, commenter_id]).sample
  pcr.post_comment = pc
  pcr.body = Faker::Lorem.paragraph_by_chars(number: 350) + "\r\n\r\n" + Faker::Lorem.paragraph_by_chars(number: 350)
  pcr.save!
end

a = Announcement.new
a.title = "Some announcement title"
a.body = "If you were a real user on a non-staging site, this post would contain some useful information. But now it's just filler text."
a.user = User.first
a.save!

ar = AnnouncementReply.new
ar.announcement = a
ar.body = "This would be a question about site rules in the real world, probably."
ar.user = User.last
ar.save!


