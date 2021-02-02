require 'rails_helper'

RSpec.describe 'Recipients', type: :request do

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
      application: application, resource_owner_id: user.id, scopes: :read
    )
  end

  path '/schools/{school_id}/recipients' do
    get 'Get all recipients for school' do
      tags 'Recipients'
      produces 'application/json'
      parameter name: :school_id, in: :path

      subject do
        get request_url, params: request_body.to_json, headers: request_headers
        response
      end
      let(:request_url) { "/schools/#{school_id}/recipients" }
      let(:request_body) { { } }
      let(:request_headers) { { AUTHORIZATION: "Bearer #{token.token}" } }
      let(:school_id) { school.id }
      let(:school) { FactoryBot.create :school }
      let!(:recipients) { FactoryBot.create_list :recipient, 3, school: school }
      let(:expected_body) do
        recipients.map do |recipient|
          recipient.attributes.each_with_object({}) do |(k, v), hsh|
            hsh[k] = k == 'created_at' || k == 'updated_at' ? v.strftime('%FT%T.%LZ'): v
          end
        end
      end

      response '200', 'Returns all recipients for school' do
        it 'returns all recipients for school', :aggregate_failures do
          expect(subject).to have_http_status(:ok)
          expect(subject.parsed_body).to eq(expected_body)
        end
      end

      response '404', 'Not Found' do
        it_behaves_like 'Not Found Error'
      end
    end
  end

  path '/schools/{school_id}/recipients' do
    post 'Creates a recipient' do
      tags 'Recipients'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :school_id, in: :path
      parameter name: :recipient, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          address: { type: :string },
        },
        required: ['name email address']
      }

      subject do
        post request_url, params: request_body.to_json, headers: request_headers
        response
      end
      let(:request_url) { "/schools/#{school_id}/recipients" }
      let(:request_body) do
        {
          name: 'Aditya Elton Douglas',
          email: 'no-email@noemail.com',
          address: '282 Kevin Brook, Imogeneborough, CA 58517',
        }
      end
      let(:request_headers) do
        { CONTENT_TYPE: 'application/json', AUTHORIZATION: "Bearer #{token.token}" }
      end
      let(:school_id) { school.id }
      let(:school) { FactoryBot.create :school }
      let(:expected_body) do
        {
          'name' => 'Aditya Elton Douglas',
          'email' => 'no-email@noemail.com',
          'address' => '282 Kevin Brook, Imogeneborough, CA 58517',
        }
      end

      response '200', 'Recipients Created' do
        it 'creates recipient and returns the record', :aggregate_failures do
          expect { subject }.to change { Recipient.count }.from(0).to(1)
          expect(subject).to have_http_status(:ok)
          expect(subject.parsed_body).to include(expected_body)
        end
      end
      response '422', 'Unprocessable Entity' do
        it_behaves_like 'Unprocessable Entity Error'
      end
    end
  end

  path '/schools/{school_id}/recipients/{recipient_id}' do
    put 'Updates a recipient' do
      tags 'Recipients'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :school_id, in: :path
      parameter name: :recipient_id, in: :path
      parameter name: :recipient, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          address: { type: :string },
        },
        required: ['name email address']
      }

      subject do
        put request_url, params: request_body.to_json, headers: request_headers
        response
      end
      let(:request_url) { "/schools/#{school_id}/recipients/#{recipient_id}" }
      let(:request_body) { { email: 'has-email@noemail.com' } }
      let(:request_headers) do
        { CONTENT_TYPE: 'application/json', AUTHORIZATION: "Bearer #{token.token}" }
      end
      let(:school_id) { school.id }
      let(:school) { FactoryBot.create :school }
      let(:recipient_id) { recipient.id }
      let!(:recipient) { FactoryBot.create :recipient, school: school, email: 'no-email@noemail.com' }
      let(:expected_body) do
        recipient.attributes.slice([:id, :name, :address, :school_id]).merge({
          'email' => 'has-email@noemail.com',
        })
      end

      response '200', 'Recipient Updated' do
        it 'updates the recipient and returns the record', :aggregate_failures do
          expect { subject }.to change { recipient.reload.email }.
            from('no-email@noemail.com').to('has-email@noemail.com')
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

  path '/schools/{school_id}/recipients/{recipient_id}' do
    delete 'Deletes a recipient' do
      tags 'Recipients'
      produces 'application/json'
      parameter name: :school_id, in: :path
      parameter name: :recipient_id, in: :path

      subject do
        delete request_url, params: request_body.to_json, headers: request_headers
        response
      end
      let(:request_url) { "/schools/#{school_id}/recipients/#{recipient_id}" }
      let(:request_body) { { } }
      let(:request_headers) do
        { CONTENT_TYPE: 'application/json', AUTHORIZATION: "Bearer #{token.token}" }
      end
      let(:school_id) { school.id }
      let(:school) { FactoryBot.create :school }
      let(:recipient_id) { recipient.id }
      let!(:recipient) { FactoryBot.create :recipient, school: school }
      let(:expected_body) do
        recipient.attributes.slice([:id, :name, :address, :email, :school_id])
      end

      response '200', 'Recipient Deleted' do
        it 'deletes the recipient and returns the record', :aggregate_failures do
          expect { subject }.to change { Recipient.count }.from(1).to(0)
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
      get request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}/recipients" }
    let(:request_body) { { } }
    let(:request_headers) { { AUTHORIZATION: "Bearer #{token.token}" } }
    let(:school_id) { school.id }
    let(:school) { FactoryBot.create :school }

    it { is_expected.to have_http_status(:ok) }

    context 'unauthorized' do
      let(:request_headers) { { } }
      it { is_expected.to have_http_status(:unauthorized) }
    end
  end
end
