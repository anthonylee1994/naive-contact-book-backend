require 'swagger_helper'

def friendship_create_parameters
  parameter name: :data, in: :body, schema: {
    type: :object,
    properties: {
      target_id: { type: :integer, description: 'Target User ID' },
      _otp_code: { type: :string, description: 'OTP Code' },
      tags_attributes: {
        type: :object,
        nullable: true,
        properties: {
          id: { type: :integer, description: 'Tag ID', nullable: true },
          value: { type: :string, description: 'Tag Value' },
          _destroy: { type: :boolean, description: 'Delete?', nullable: true }
        }
      }
    }
  }
end

def friendship_update_parameters
  parameter name: :id, in: :path, type: :integer

  parameter name: :data, in: :body, schema: {
    type: :object,
    properties: {
      tags_attributes: {
        type: :object,
        nullable: true,
        properties: {
          id: { type: :integer, description: 'Tag ID', nullable: true },
          value: { type: :string, description: 'Tag Value' },
          _destroy: { type: :boolean, description: 'Delete?', nullable: true }
        }
      }
    }
  }
end

def user_response_schema
  {
    type: :object,
    properties: {
      name: { type: :string },
      created_at: { type: :string, format: :date_time },
      updated_at: { type: :string, format: :date_time },
      avatar_url: { type: :string, format: :uri, nullable: true },
      user_contacts: {
        type: :array,
        items: {
          properties: {
            id: { type: :integer, description: 'User Contact ID' },
            contact_type: { type: :string, description: 'Contact Type' },
            created_at: { type: :string, format: :date_time },
            updated_at: { type: :string, format: :date_time },
            contact: {
              type: :object,
              anyOf: [
                {
                  type: :object,
                  description: 'WhatsApp Contact',
                  properties: {
                    id: { type: :integer, description: 'Contact ID' },
                    phone_number: { type: :string },
                    created_at: { type: :string, format: :date_time },
                    updated_at: { type: :string, format: :date_time }
                  }
                },
                {
                  type: :object,
                  description: 'Telegram Contact',
                  properties: {
                    id: { type: :integer, description: 'Contact ID' },
                    username: { type: :string },
                    created_at: { type: :string, format: :date_time },
                    updated_at: { type: :string, format: :date_time }
                  }
                },
                {
                  type: :object,
                  description: 'Address Contact',
                  properties: {
                    id: { type: :integer, description: 'Contact ID' },
                    address: { type: :string },
                    created_at: { type: :string, format: :date_time },
                    updated_at: { type: :string, format: :date_time }
                  }
                }
              ]
            }
          }
        }
      }
    },
    required: %w[name created_at updated_at]
  }
end

def friendship_response_schema
  {
    properties: {
      user_id: { type: :integer, description: 'User ID' },
      target_id: { type: :integer, description: 'Target User ID' },
      created_at: { type: :string, format: :date_time },
      updated_at: { type: :string, format: :date_time },
      target: user_response_schema
    }
  }
end

def list_friendship_response_schema
  schema type: :array,
         items: friendship_response_schema
end

def show_friendship_response_schema
  schema({ type: :object }.merge(items: friendship_response_schema))
end

describe 'Friendship API' do
  let(:bob) do
    User.create!(
      name: 'Bob', _avatar_attributes: { 'file' => avatar_image },
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
          contact_type: 'AddressContact',
          contact_attributes: {
            address: 'YOYOYO'
          }
        },
        {
          display_order: 3,
          contact_type: 'TelegramContact',
          contact_attributes: {
            username: 'heyhey123'
          }
        }
      ]
    )
  end
  let(:alice) { User.create!(name: 'Alice') }
  let(:avatar_image) { fixture_file_upload('avatar.jpg', 'image/jpeg') }
  let(:bob_friendship) { bob.friendships.create!(target: alice, _otp_code: alice.otp_code) }

  path '/friendships' do
    post 'Create friendship' do
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: {}]

      friendship_create_parameters

      response '201', 'updated contact' do
        let(:Authorization) { "Bearer #{bob.secret}" }
        let(:data) { { target_id: alice.id, _otp_code: alice.otp_code } }

        run_test! do |_response|
          expect(bob.friends.include?(alice)).to be true
          expect(alice.friends.include?(bob)).to be true
        end
      end
    end

    get 'List friendship' do
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: {}]

      parameter name: :tag, in: :query, type: :string
      parameter name: :name, in: :query, type: :string

      response '200', 'list friendships' do
        let(:Authorization) { "Bearer #{alice.secret}" }
        let(:tag) { '' }
        let(:name) { 'bob' }

        list_friendship_response_schema

        before do
          bob_friendship
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.first['target']['avatar_url']).not_to be_nil
          expect(data.first['target']['user_contacts'].count).to eq 3
        end
      end
    end
  end

  path '/friendships/{id}' do
    get 'Show friendship' do
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: {}]

      parameter name: :id, in: :path, type: :integer

      response '200', 'get friendship' do
        let(:id) { bob_friendship.id }
        let(:Authorization) { "Bearer #{bob.secret}" }

        show_friendship_response_schema
        run_test!
      end
    end

    put 'Update friendship' do
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: {}]

      friendship_update_parameters

      response '200', 'updated friendship' do
        let(:id) { bob_friendship.id }
        let(:Authorization) { "Bearer #{bob.secret}" }
        let(:data) do
          {
            tags_attributes: [
              { value: 'good' },
              { value: 'crazy' },
              { value: 'yoyo' }
            ]
          }
        end

        show_friendship_response_schema
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['tags'].pluck('value')).to eq %w[good crazy yoyo]
        end
      end
    end

    delete 'Delete friendship' do
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: {}]

      parameter name: :id, in: :path, type: :integer

      response '204', 'delete friendship' do
        let(:id) { bob_friendship.id }
        let(:Authorization) { "Bearer #{bob.secret}" }

        run_test! do |_response|
          expect(Friendship.exists?(bob_friendship.id)).to be false
          expect(alice.friendships.count).to eq 0
        end
      end
    end
  end
end
