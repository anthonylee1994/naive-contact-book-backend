# == Schema Information
#
# Table name: address_contacts
#
#  id         :integer          not null, primary key
#  address    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AddressContact < ApplicationRecord
  include AsContact
end
