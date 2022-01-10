# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string
#  secret     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  r          :float
#
# Indexes
#
#  index_users_on_secret  (secret) UNIQUE
#

class User < ApplicationRecord
  attr_accessor :_avatar_attributes

  has_one_attached :avatar
  validates :name, presence: true, allow_blank: false

  before_validation :init_secret, on: :create
  before_commit :upload_avatar, if: -> { _avatar_attributes && _avatar_attributes['file'] }
  before_commit :purge_avatar, if: -> { _avatar_attributes && _avatar_attributes['purge'] }

  def init_secret
    self.secret = SecureRandom.hex(16)
  end

  def upload_avatar
    avatar.attach(_avatar_attributes['file'])
  end

  def purge_avatar
    avatar.purge if avatar.attached?
  end
end
