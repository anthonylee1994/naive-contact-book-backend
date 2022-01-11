# == Schema Information
#
# Table name: whats_app_contacts
#
#  id           :integer          not null, primary key
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class WhatsAppContact < ApplicationRecord
  include AsContact
end
