# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string
#  secret     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_secret  (secret) UNIQUE
#

class User < ApplicationRecord
  validates :name, presence: true, allow_blank: false

  before_validation :init_secret, on: :create

  def init_secret
    self.secret = SecureRandom.hex(16)
  end
end
