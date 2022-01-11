require 'swagger_helper'

describe 'Contacts API' do
  let(:anthony) { User.create!(name: 'Anthony') }

  path '/update_contacts' do
    put 'Update Contacts' do
      consumes 'application/json'
      produces 'application/json'

      security [Bearer: []]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user_contacts_attributes: {
            nullable: true,
            type: :array,
            description: 'User Contact',
            items: {
              type: :object,
              properties: {
                id: { type: :integer, description: 'User Contact ID', nullable: true },
                contact_type: { type: :string, description: 'Contact Type' },
                _destroy: { type: :boolean, description: 'Delete?', nullable: true },
                contact_attributes: {
                  type: :object,
                  properties: {
                    phone_number: { type: :string, nullable: true },
                    username: { type: :string, nullable: true },
                    address: { type: :string, nullable: true }
                  }
                }
              }
            }
          }
        },
        required: %w[user_contacts_attributes]
      }

      response '200', 'updated contact' do
        let(:Authorization) do
          "Bearer #{anthony.secret}"
        end

        let(:data) do
          {
            user_contacts_attributes: [
              {
                display_order: 1,
                contact_type: 'WhatsAppContact',
                contact_attributes: {
                  phone_number: '123'
                }
              },
              {
                display_order: 2,
                contact_type: 'WhatsAppContact',
                contact_attributes: {
                  phone_number: '456'
                }
              },
              {
                display_order: 3,
                contact_type: 'WhatsAppContact',
                contact_attributes: {
                  phone_number: '789'
                }
              }
            ]
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user_contacts'].count).to eq 3
          expect(data['user_contacts'][0]['contact']['phone_number']).to eq '123'
          expect(data['user_contacts'][1]['contact']['phone_number']).to eq '456'
          expect(data['user_contacts'][2]['contact']['phone_number']).to eq '789'
        end
      end
    end
  end
end
