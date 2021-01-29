require 'rails_helper'

RSpec.describe 'Schools', type: :request do
  describe 'create school' do
    subject do
      post request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { '/schools' }
    let(:request_body) { { name: 'South Texas College' } }
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
    let(:expected_body) { { 'name' => 'South Texas College' } }

    it 'creates a school and returns the record', :aggregate_failures do
      expect { subject }.to change { School.count }.from(0).to(1)
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to include(expected_body)
    end
  end

  describe 'update school' do
    subject do
      put request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}" }
    let(:request_body) { { name: 'University Of Michigan' } }
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }

    let!(:school) { FactoryBot.create :school, name: 'South Texas College' }
    let(:school_id) { school.id }
    let(:expected_body) { { 'name' => 'University Of Michigan' } }

    it 'updates the school and returns the record', :aggregate_failures do
      expect { subject }.to change { school.reload.name }.
        from('South Texas College').to('University Of Michigan')
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to include(expected_body)
    end
  end

  describe 'delete school' do
    subject do
      delete request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}" }
    let(:request_body) { { } }
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }

    let!(:school) { FactoryBot.create :school, name: 'South Texas College' }
    let(:school_id) { school.id }
    let(:expected_body) { {'name' => 'South Texas College' } }

    it 'deletes the school and returns the record', :aggregate_failures do
      expect { subject }.to change { School.count }.from(1).to(0)
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to include(expected_body)
    end
  end
end
