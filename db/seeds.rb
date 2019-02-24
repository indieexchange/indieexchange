# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

(10..100).each do |n|
  u = User.new(
    first_name: "Test#{n}",
    last_name: "Account#{n}",
    about_me: "Numerous diseases can cause a cat to feel hunger, thirst, or pain, all of which can lead to excessive meowing. ... Cats often meow to initiate play, petting, or to get you to talk to them. If you want to cut down on attention-seeking meows, stop responding when it happens. Only give her attention when she's quiet.",
    email: "test#{n}@gmail.com",
    password: "passwordpassword",
    password_confirmation: "passwordpassword",
    )
  u.skip_confirmation!
  u.save
end

n = 0
words = ["one", "two", "three", "four", "five", "six", "SEVEN", "Eight"]
words2 = ["senior", "frontend", "software", "engineer", "position", "ruby", "rails", "python"]
Subcategory.all.each do |subcategory|
  4.times do |i|
    post = Post.new(
      title: (([nil]*4).collect{ |x| SecureRandom.hex(4) } + [words[i*2], words[i*2+1]]).join(" "),
      description: (([nil]*20).collect{ |x| SecureRandom.hex(4) } + [words2[i*2], words2[i*2+1]]).join(" "),
      price: (i + 1.0)/2,
      subcategory: subcategory,
      is_published: true,
      is_visible: true,
      is_offering: [true, false].sample,
      user_id: User.all.map(&:id).sample
      )
    post.save!
    n += 1
  end
end