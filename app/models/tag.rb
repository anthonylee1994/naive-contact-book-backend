# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  value         :string
#  friendship_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_tags_on_friendship_id  (friendship_id)
#

class Tag < ApplicationRecord
  belongs_to :friendship

  validates :value, presence: true, allow_blank: false
end
