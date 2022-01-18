# == Schema Information
#
# Table name: friendships
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  target_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_friendships_on_target_id  (target_id)
#  index_friendships_on_user_id    (user_id)
#

class Friendship < ApplicationRecord
  attr_accessor :_otp_code

  belongs_to :user
  belongs_to :target, class_name: 'User'

  has_many :tags, dependent: :destroy

  accepts_nested_attributes_for :tags, allow_destroy: true

  validates :user_id, uniqueness: { scope: :target_id }

  validate :valid_otp_code, on: :create
  validate :no_self, on: :create

  after_create :create_inverse_relationship, unless: -> { target.friends.include?(user) }
  after_destroy :destroy_inverse_relationship, if: -> { target.friends.include?(user) }

  def valid_otp_code
    puts _otp_code
    errors.add(:base, 'invalid_otp') unless target.authenticate_otp(_otp_code, drift: 60)
  end

  def no_self
    errors.add(:base, 'no_self') unless target != user
  end

  def create_inverse_relationship
    target.friendships.create!(target: user, _otp_code: user.otp_code)
  end

  def destroy_inverse_relationship
    target.friendships.find_by(target: user).destroy!
  end
end
