require 'swagger_helper'

describe 'Users API' do
  let(:anthony) { User.create!(name: 'Anthony') }

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
