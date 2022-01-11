# == Schema Information
#
# Table name: user_contacts
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  contact_type  :string           not null
#  contact_id    :integer          not null
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_user_contacts_on_contact  (contact_type,contact_id)
#  index_user_contacts_on_user_id  (user_id)
#

class UserContact < ApplicationRecord
  belongs_to :user
  belongs_to :contact, polymorphic: true

  ALLOWED_CONTACT_TYPES = %w[AddressContact TelegramContact WhatsAppContact].freeze

  validates :contact_type, presence: true, inclusion: { in: ALLOWED_CONTACT_TYPES }

  accepts_nested_attributes_for :contact

  def build_contact(params)
    self.contact = contact_type.constantize.new(params)
  end
end
