require 'swagger_helper'

def user_response_schema
  schema type: :object,
         properties: {
           name: { type: :string },
           created_at: { type: :string, format: :date_time },
           updated_at: { type: :string, format: :date_time },
           avatar_url: { type: :string, format: :uri, nullable: true },
           secret: { type: :string },
           otp_code: { type: :string },
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
         required: %w[name created_at updated_at secret]
end

def multipart_request
  consumes 'multipart/form-data'
  produces 'application/json'
end

def json_request
  consumes 'application/json'
  produces 'application/json'
end

def user_parameters
  parameter name: :data, in: :formData, schema: {
    type: :object,
    properties: {
      name: { type: :string, description: 'User Name' },
      '_avatar_attributes[file]': { type: :file, description: 'Avatar File' },
      '_avatar_attributes[purge]': { type: :boolean, description: 'Purge Avatar?' }
    }
  }
end

describe 'Users API' do
  let(:anthony) { User.create!(name: 'Anthony') }
  let(:avatar_image) { fixture_file_upload('avatar.jpg', 'image/jpeg') }

  path '/sign_up' do
    post 'Sign up' do
      multipart_request
      user_parameters

      response '201', 'user created' do
        let(:data) { { name: 'Anthony', '_avatar_attributes[file]': avatar_image } }

        user_response_schema

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq 'Anthony'
          expect(data['secret']).not_to be_nil
          expect(data['avatar_url']).not_to be_nil
        end
      end

      response '422', 'user should create with name', document: false do
        let(:data) { { name: nil } }

        run_test!
      end

      response '422', 'user should create with non-blank name', document: false do
        let(:data) { { name: '' } }
        run_test!
      end
    end
  end

  path '/sign_in' do
    post 'Sign in' do
      json_request

      security [Bearer: []]

      response '200', 'sign in' do
        let(:Authorization) do
          "Bearer #{anthony.secret}"
        end

        user_response_schema

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq 'Anthony'
          expect(data['secret']).to eq anthony.secret
          expect(data['otp_code']).not_to be_nil
        end
      end
    end
  end

  path '/me' do
    get 'Show current user' do
      json_request

      security [Bearer: []]

      response '200', 'get current user' do
        let(:Authorization) do
          "Bearer #{anthony.secret}"
        end

        user_response_schema

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq 'Anthony'
          expect(data['secret']).to eq anthony.secret
          expect(data['otp_code']).not_to be_nil
        end
      end
    end

    put 'Update user' do
      multipart_request

      security [Bearer: []]
      user_parameters

      response '200', 'update user info' do
        let(:Authorization) do
          "Bearer #{anthony.secret}"
        end

        let(:data) { { name: 'Tom' } }

        user_response_schema

        run_test! do |_response|
          expect(anthony.reload.name).to eq 'Tom'
        end
      end
    end

    put 'Add user avatar' do
      multipart_request

      security [Bearer: []]

      user_parameters

      response '200', 'update user info', document: false do
        let(:Authorization) do
          "Bearer #{anthony.secret}"
        end

        let(:data) { { '_avatar_attributes[file]': avatar_image } }

        run_test! do |_response|
          expect(anthony.reload.avatar.reload.blob.filename.to_s).to eq 'avatar.jpg'
        end
      end
    end

    put 'Update user avatar' do
      multipart_request

      security [Bearer: []]

      user_parameters

      response '200', 'update user info', document: false do
        let(:user) do
          anthony.update!(_avatar_attributes: { 'file' => fixture_file_upload('xxx.jpg', 'image/jpeg') })
          anthony
        end

        let(:Authorization) do
          "Bearer #{user.secret}"
        end

        let(:data) { { '_avatar_attributes[file]': avatar_image } }

        run_test! do |_response|
          expect(anthony.reload.avatar.reload.blob.filename.to_s).to eq 'avatar.jpg'
        end
      end
    end

    put 'Delete user avatar' do
      multipart_request

      security [Bearer: []]

      user_parameters

      response '200', 'update user info', document: false do
        let(:user) do
          anthony.update!(_avatar_attributes: { 'file' => fixture_file_upload('xxx.jpg', 'image/jpeg') })
          anthony
        end

        let(:Authorization) do
          "Bearer #{user.secret}"
        end

        let(:data) { { '_avatar_attributes[purge]': true } }

        run_test! do |_response|
          expect(anthony.reload.avatar.attached?).to be false
        end
      end
    end

    delete 'Delete current user' do
      json_request

      security [Bearer: []]

      response '204', 'delete current user' do
        let(:Authorization) do
          "Bearer #{anthony.secret}"
        end

        run_test! do |_response|
          expect(User.exists?(anthony.id)).to be false
        end
      end
    end
  end
end
