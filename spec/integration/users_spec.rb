require 'swagger_helper'

describe 'Users API' do
  let(:anthony) { User.create!(name: 'Anthony') }
  let(:avatar_image) { fixture_file_upload('avatar.jpg', 'image/jpeg') }

  path '/sign_up' do
    post 'Sign up' do
      consumes 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: %w[name]
      }

      response '201', 'user created' do
        let(:user) { { name: 'Anthony' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq 'Anthony'
          expect(data['secret']).not_to be_nil
        end
      end

      response '422', 'user should create with name', document: false do
        let(:user) { {} }
        run_test!
      end

      response '422', 'user should create with non-blank name', document: false do
        let(:user) { { name: '' } }
        run_test!
      end
    end
  end

  path '/sign_in' do
    post 'Sign in' do
      consumes 'application/json'
      security [Bearer: {}]

      response '200', 'sign in' do
        let(:Authorization) do
          "Bearer #{anthony.secret}"
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq 'Anthony'
          expect(data['secret']).to eq anthony.secret
        end
      end
    end
  end

  path '/me' do
    get 'Show current user' do
      consumes 'application/json'
      security [Bearer: {}]

      response '200', 'get current user' do
        let(:Authorization) do
          "Bearer #{anthony.secret}"
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq 'Anthony'
          expect(data['secret']).to eq anthony.secret
        end
      end
    end

    put 'Update user' do
      consumes 'application/json'
      security [Bearer: {}]

      parameter name: :user_info, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: %w[name]
      }

      response '204', 'update user info' do
        let(:Authorization) do
          "Bearer #{anthony.secret}"
        end

        let(:user_info) { { name: 'Tom' } }

        run_test! do |_response|
          expect(anthony.reload.name).to eq 'Tom'
        end
      end
    end

    put 'Add user avatar' do
      consumes 'multipart/form-data'
      security [Bearer: {}]

      parameter name: :'_avatar_attributes[file]', in: :formData, type: :file

      response '204', 'update user info' do
        let(:Authorization) do
          "Bearer #{anthony.secret}"
        end

        let(:'_avatar_attributes[file]') { avatar_image }

        run_test! do |_response|
          expect(anthony.reload.avatar.reload.blob.filename.to_s).to eq 'avatar.jpg'
        end
      end
    end

    put 'Update user avatar' do
      consumes 'multipart/form-data'
      security [Bearer: {}]

      parameter name: :'_avatar_attributes[file]', in: :formData, type: :file

      response '204', 'update user info' do
        let(:user) do
          anthony.update!(_avatar_attributes: { 'file' => fixture_file_upload('xxx.jpg', 'image/jpeg') })
          anthony
        end

        let(:Authorization) do
          "Bearer #{user.secret}"
        end

        let(:'_avatar_attributes[file]') { avatar_image }

        run_test! do |_response|
          expect(anthony.reload.avatar.reload.blob.filename.to_s).to eq 'avatar.jpg'
        end
      end
    end

    put 'Delete user avatar' do
      consumes 'multipart/form-data'
      security [Bearer: {}]

      parameter name: :'_avatar_attributes[purge]', in: :formData, type: :boolean

      response '204', 'update user info' do
        let(:user) do
          anthony.update!(_avatar_attributes: { 'file' => fixture_file_upload('xxx.jpg', 'image/jpeg') })
          anthony
        end

        let(:Authorization) do
          "Bearer #{user.secret}"
        end

        let(:'_avatar_attributes[purge]') { true }

        run_test! do |_response|
          expect(anthony.reload.avatar.attached?).to be false
        end
      end
    end

    delete 'Delete current user' do
      consumes 'application/json'
      security [Bearer: {}]

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
