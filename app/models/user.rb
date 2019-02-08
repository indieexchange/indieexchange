class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable, :lockable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates_acceptance_of :terms_of_service, message: "must be accepted"
  validates_acceptance_of :age,              message: "must be over 18"

  def display_name
    value = username || [first_name, last_name].join(" ")
    value.truncate(20)
  end
end
