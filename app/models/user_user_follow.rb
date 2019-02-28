class UserUserFollow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :target, class_name: "User"

  validate :cant_follow_self
  validate :cant_follow_twice

  def cant_follow_self
    if follower == target
      errors[:base] << "You can't follow yourself"
    end
  end

  def cant_follow_twice
    if UserUserFollow.where(follower: follower, target: target).any?
      errors[:base] << "You're already following this user"
    end
  end
end
