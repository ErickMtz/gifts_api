require 'rails_helper'

RSpec.describe 'Recipients', type: :request do
  describe 'index recipients' do
    subject do
      get request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}/recipients" }
    let(:request_body) { { } }
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
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

    it 'returns all recipients for school', :aggregate_failures do
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to eq(expected_body)
    end
  end

  describe 'create a recipient' do
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
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
    let(:school_id) { school.id }
    let(:school) { FactoryBot.create :school }
    let(:expected_body) do
      {
        'name' => 'Aditya Elton Douglas',
        'email' => 'no-email@noemail.com',
        'address' => '282 Kevin Brook, Imogeneborough, CA 58517',
      }
    end

    it 'creates recipient and returns the record', :aggregate_failures do
      expect { subject }.to change { Recipient.count }.from(0).to(1)
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to include(expected_body)
    end
  end

  describe 'update a recipient' do
    subject do
      put request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}/recipients/#{recipient_id}" }
    let(:request_body) { { email: 'has-email@noemail.com' } }
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
    let(:school_id) { school.id }
    let(:school) { FactoryBot.create :school }
    let(:recipient_id) { recipient.id }
    let!(:recipient) { FactoryBot.create :recipient, school: school, email: 'no-email@noemail.com' }
    let(:expected_body) do
      recipient.attributes.slice([:id, :name, :address, :school_id]).merge({
        'email' => 'has-email@noemail.com',
      })
    end

    it 'updates the recipient and returns the record', :aggregate_failures do
      expect { subject }.to change { recipient.reload.email }.
        from('no-email@noemail.com').to('has-email@noemail.com')
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to include(expected_body)
    end
  end

  describe 'delete a recipient' do
    subject do
      delete request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}/recipients/#{recipient_id}" }
    let(:request_body) { { } }
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
    let(:school_id) { school.id }
    let(:school) { FactoryBot.create :school }
    let(:recipient_id) { recipient.id }
    let!(:recipient) { FactoryBot.create :recipient, school: school }
    let(:expected_body) do
      recipient.attributes.slice([:id, :name, :address, :email, :school_id])
    end

    it 'deletes the recipient and returns the record', :aggregate_failures do
      expect { subject }.to change { Recipient.count }.from(1).to(0)
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to include(expected_body)
    end
  end
end
