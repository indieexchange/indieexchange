class UpdateUsersToThreeMonthMemberships < ActiveRecord::Migration[5.2]
  def change
    # temporary issue here.  site is still growing, so we want the 45 day trial to be extended to 90 day
    # trial for anyone already signed up.  similarly, anyone who's paid gets 2 months free.
    User.all.each do |user|
      if user.is_trial_period
        user.trial_until += 2.months
      elsif user.is_verified
        user.verified_until += 2.months
      end

      user.save!
    end
  end
end
