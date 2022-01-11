# == Schema Information
#
# Table name: telegram_contacts
#
#  id         :integer          not null, primary key
#  username   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TelegramContact < ApplicationRecord
  include AsContact
end
