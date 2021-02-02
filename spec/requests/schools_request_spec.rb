require 'rails_helper'

RSpec.describe 'Schools', type: :request do
  let(:application) do
    Doorkeeper::Application.create({
      name: 'ApptegyUser',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
    })
  end
  let(:user) do
    User.create(email: 'user@email.com', password: '123456', password_confirmation: '123456')
  end
  let!(:token) do
    Doorkeeper::AccessToken.create(
      application: application, resource_owner_id: user.id, scopes: :admin
    )
  end

  path '/schools' do
    post 'Creates a school' do
      tags 'Schools'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :school, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
        },
        required: ['name']
      }

      subject do
        post request_url, params: request_body.to_json, headers: request_headers
        response
      end
      let(:request_url) { '/schools' }
      let(:request_body) { { name: 'South Texas College' } }
      let(:request_headers) do
        { CONTENT_TYPE: 'application/json', AUTHORIZATION: "Bearer #{token.token}" }
      end
      let(:expected_body) { { 'name' => 'South Texas College' } }

      response '200', 'School Created' do
        it 'creates a school and returns the record', :aggregate_failures do
          expect { subject }.to change { School.count }.from(0).to(1)
          expect(subject).to have_http_status(:ok)
          expect(subject.parsed_body).to include(expected_body)
        end
      end

      response '422', 'Unprocessable Entity' do
        it_behaves_like 'Unprocessable Entity Error'
      end
    end
  end

  path '/schools/{id}' do
    put 'Updates a school' do
      tags 'Schools'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path
      parameter name: :school, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
        },
        required: ['name']
      }
      subject do
        put request_url, params: request_body.to_json, headers: request_headers
        response
      end
      let(:request_url) { "/schools/#{school_id}" }
      let(:request_body) { { name: 'University Of Michigan' } }
      let(:request_headers) do
        { CONTENT_TYPE: 'application/json', AUTHORIZATION: "Bearer #{token.token}" }
      end

      let!(:school) { FactoryBot.create :school, name: 'South Texas College' }
      let(:school_id) { school.id }
      let(:expected_body) { { 'name' => 'University Of Michigan' } }

      response '200', 'School Updated' do
        it 'updates the school and returns the record', :aggregate_failures do
          expect { subject }.to change { school.reload.name }.
            from('South Texas College').to('University Of Michigan')
          expect(subject).to have_http_status(:ok)
          expect(subject.parsed_body).to include(expected_body)
        end
      end

      response '422', 'Unprocessable Entity' do
        it_behaves_like 'Unprocessable Entity Error'
      end
      response '404', 'Not Found' do
        it_behaves_like 'Not Found Error'
      end
    end
  end

  path '/schools/{id}' do
    delete 'Deletes a School' do
      tags 'Schools'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path
      subject do
        delete request_url, params: request_body.to_json, headers: request_headers
        response
      end
      let(:request_url) { "/schools/#{school_id}" }
      let(:request_body) { { } }
      let(:request_headers) do
        { CONTENT_TYPE: 'application/json', AUTHORIZATION: "Bearer #{token.token}" }
      end

      let!(:school) { FactoryBot.create :school, name: 'South Texas College' }
      let(:school_id) { school.id }
      let(:expected_body) { {'name' => 'South Texas College' } }

      response '200', 'School Deleted' do
        it 'deletes the school and returns the record', :aggregate_failures do
          expect { subject }.to change { School.count }.from(1).to(0)
          expect(subject).to have_http_status(:ok)
          expect(subject.parsed_body).to include(expected_body)
        end
      end

      response '404', 'Not Found' do
        it_behaves_like 'Not Found Error'
      end
    end
  end

  describe 'oauth' do
    subject do
      post request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { '/schools' }
    let(:request_body) { { name: 'South Texas College' } }
    let(:request_headers) do
      { CONTENT_TYPE: 'application/json', AUTHORIZATION: "Bearer #{token.token}" }
    end
    let(:expected_body) { { 'name' => 'South Texas College' } }

    it { is_expected.to have_http_status(:ok) }

    context 'unauthorized' do
      context 'not an admin' do
        let!(:token) do
          Doorkeeper::AccessToken.create(
            application: application, resource_owner_id: user.id, scopes: :write
          )
        end
        it { is_expected.to have_http_status(:forbidden) }
      end

      context 'without token' do
        let(:request_headers) { { } }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end
  end
end
