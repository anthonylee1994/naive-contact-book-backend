# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# avatar_image_file = raiFile.new(Rails.root.join('spec/fixtures/files/avatar.jpg'))
require 'open-uri'

anthony = User.find_or_create_by!(name: 'Anthony Lee')
anthony.avatar.attach(io: URI.open(Faker::Avatar.image), filename: 'avatar.png')
anthony.update!(
  user_contacts_attributes: [
    {
      display_order: 1,
      contact_type: 'WhatsAppContact',
      contact_attributes: {
        phone_number: Faker::PhoneNumber.cell_phone_in_e164
      }
    },
    {
      display_order: 2,
      contact_type: 'WhatsAppContact',
      contact_attributes: {
        phone_number: Faker::PhoneNumber.cell_phone_in_e164
      }
    },
    {
      display_order: 3,
      contact_type: 'TelegramContact',
      contact_attributes: {
        username: Faker::Alphanumeric.alpha(number: 10)
      }
    },
    {
      display_order: 4,
      contact_type: 'AddressContact',
      contact_attributes: {
        address: Faker::Address.full_address.gsub(', ', "\n")
      }
    },
    {
      display_order: 5,
      contact_type: 'AddressContact',
      contact_attributes: {
        address: Faker::Address.full_address.gsub(', ', "\n")
      }
    }
  ]
)

ActiveRecord::Base.transaction do
  0..10.times do |_i|
    user = User.create!(
      name: Faker::Name.name,
      user_contacts_attributes: [
        {
          display_order: 1,
          contact_type: 'WhatsAppContact',
          contact_attributes: {
            phone_number: Faker::PhoneNumber.cell_phone_in_e164
          }
        },
        {
          display_order: 2,
          contact_type: 'WhatsAppContact',
          contact_attributes: {
            phone_number: Faker::PhoneNumber.cell_phone_in_e164
          }
        },
        {
          display_order: 3,
          contact_type: 'TelegramContact',
          contact_attributes: {
            username: Faker::Alphanumeric.alpha(number: 10)
          }
        },
        {
          display_order: 4,
          contact_type: 'AddressContact',
          contact_attributes: {
            address: Faker::Address.full_address.gsub(', ', "\n")
          }
        },
        {
          display_order: 5,
          contact_type: 'AddressContact',
          contact_attributes: {
            address: Faker::Address.full_address.gsub(', ', "\n")
          }
        }
      ]
    )

    user.avatar.attach(io: URI.open(Faker::Avatar.image), filename: 'avatar.png')

    anthony.friendships.create!(
      target_id: user.id,
      _otp_code: user.otp_code,
      tags_attributes: [
        { value: Faker::Computer.platform },
        { value: Faker::Computer.type },
        { value: Faker::Computer.os }
      ]
    )
  end
end
