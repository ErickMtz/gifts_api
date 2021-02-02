require 'rails_helper'

RSpec.describe 'Oauth', type: :request do
  let!(:application) do
    Doorkeeper::Application.create({
      name: 'ApptegyUser',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
    })
  end
  let!(:user) do
    User.create(email: 'user@email.com', password: '123456', password_confirmation: '123456')
  end

  path '/oauth/authorize' do
    post 'Authorize APP' do
      tags 'Oauth'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :client_id, in: :body
      parameter name: :redirect_uri, in: :body
      parameter name: :response_type, in: :body
      parameter name: :email, in: :body
      parameter name: :password, in: :body

      subject do
        post request_url, params: request_body.to_json, headers: request_headers
        response
      end
      let(:request_url) { '/oauth/authorize' }
      let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
      let(:request_body) do
        {
          client_id: client_id,
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          response_type: 'code',
          email: 'user@email.com',
          password: password
        }
      end
      let(:client_id) { application.uid }
      let(:password) { '123456' }

      response '200', 'Authorizes app and returns code' do
        it :aggregate_failures do
          expect(subject).to have_http_status(:ok)
          expect(subject.body).to include('code')
        end
      end

      context 'missing params' do
        let(:client_id) { nil }
        response '400', 'Bad credentials' do
          it :aggregate_failures do
            expect(subject).to have_http_status(:bad_request)
            expect(subject.body).to include('Missing required parameter: client_id')
          end
        end
      end

      context 'invalid user' do
        let(:password) { 'wrong password' }
        response '401', 'Bad request' do
          it :aggregate_failures do
            expect(subject).to have_http_status(:unauthorized)
            expect(subject.body).to be_empty
          end
        end
      end
    end
  end

  path '/oauth/token' do
    post 'Get Token' do
      tags 'Oauth'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :client_id, in: :body
      parameter name: :client_secret, in: :body
      parameter name: :redirect_uri, in: :body
      parameter name: :code, in: :body
      parameter name: :grant_type, in: :body

      subject do
        post request_url, params: request_body.to_json, headers: request_headers
        response
      end
      let(:request_url) { '/oauth/token' }
      let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
      let!(:access_grant) do
        Doorkeeper::AccessGrant.create!({
          resource_owner_id: user.id,
          application: application,
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          expires_in: 1.day,
        })
      end
      let(:request_body) do
        {
          client_id: client_id,
          client_secret: application.secret,
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          code: access_grant.token,
          grant_type: 'authorization_code',
        }
      end
      let(:client_id) { application.uid }

      response '200', 'Creates the token' do
        it '', :aggregate_failures do
          expect(subject).to have_http_status(:ok)
          expect(subject.body).to include('access_token')
        end
      end

      response '401', 'Unauthorized' do
        let(:client_id) { nil }
        it '', :aggregate_failures do
          expect(subject).to have_http_status(:unauthorized)
        end
      end
    end
  end
end