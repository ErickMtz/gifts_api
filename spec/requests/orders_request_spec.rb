require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  describe 'index orders' do
    subject do
      get request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}/orders" }
    let(:request_body) { { } }
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
    let(:school_id) { school.id }
    let(:school) { FactoryBot.create :school }
    let!(:orders) { FactoryBot.create_list :order, 3, :received, school: school, gifts: ['MUG'] }
    let(:expected_body) do
      orders.map do |order|
        order.attributes.each_with_object({}) do |(k, v), hsh|
          hsh[k] = k == 'created_at' || k == 'updated_at' ? v.strftime('%FT%T.%LZ'): v
        end
      end
    end

    it 'returns all orders for school', :aggregate_failures do
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to eq(expected_body)
    end
  end

  describe 'create an order' do
    subject do
      post request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}/orders" }
    # for some reason recipients need to be sent in this way O.o
    let(:request_body) do
      {
        order: {
          gifts: ['MUG'],
          recipients: recipients.map(&:id),
          send_email: true,
        }
      }
    end
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
    let(:school_id) { school.id }
    let(:school) { FactoryBot.create :school }
    let(:recipients) { FactoryBot.create_list :recipient, 2, school: school }
    let(:expected_body) do
      {
        'gifts' => ['MUG'],
        'send_email' => true,
        'school_id' => school_id,
      }
    end

    it 'creates order and returns the record', :aggregate_failures do
      expect { subject }.to change { Order.count }.from(0).to(1)
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to include(expected_body)
    end

    context 'the school does not exist' do
      let(:school_id) { 0 }
      
      it 'does not create order and returns an error', :aggregate_failures do
        expect { subject }.to_not change { Order.count }.from(0)
        expect(subject).to have_http_status(:unprocessable_entity)
        expect(subject.parsed_body['error_message']).to eq('Validation failed: School must exist')
      end
    end
  end

  describe 'update an order' do
    subject do
      put request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}/orders/#{order_id}" }
    let(:request_body) { { send_email: true } }
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
    let(:school_id) { school.id }
    let(:school) { FactoryBot.create :school }
    let(:order_id) { order.id }
    let!(:order) { FactoryBot.create :order, :received, school: school }
    let(:expected_body) do
      order.attributes.slice([:id, :gifts, :school_id]).merge({'send_email' => true})
    end

    it 'updates the order and returns the record', :aggregate_failures do
      expect { subject }.to change { order.reload.send_email }.from(false).to(true)
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to include(expected_body)
    end
  end

  describe 'ship an order' do
    subject do
      post request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}/orders/#{order_id}/ship" }
    let(:request_body) { { } }
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
    let(:school_id) { school.id }
    let(:school) { FactoryBot.create :school }
    let!(:order) { FactoryBot.create :order, :received, school: school, gifts: ['MUG'] }
    let(:order_id) { order.id }
    let(:expected_body) do
      order.attributes.slice([:id, :gifts, :recipients, :school_id]).merge({
        'status' => 'ORDER_SHIPPED',
      })
    end

    it 'ships the order', :aggregate_failures do
      expect { subject }.to change { order.reload.status }.
        from('ORDER_RECEIVED').to('ORDER_SHIPPED')
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to include(expected_body)
    end
  end

  describe 'cancel an order' do
    subject do
      post request_url, params: request_body.to_json, headers: request_headers
      response
    end
    let(:request_url) { "/schools/#{school_id}/orders/#{order_id}/cancel" }
    let(:request_body) { { } }
    let(:request_headers) { { CONTENT_TYPE: 'application/json' } }
    let(:school_id) { school.id }
    let(:school) { FactoryBot.create :school }
    let!(:order) { FactoryBot.create :order, :received, school: school, gifts: ['MUG'] }
    let(:order_id) { order.id }
    let(:expected_body) do
      order.attributes.slice([:id, :gifts, :recipients, :school_id, :send_email]).merge({
        'status' => 'ORDER_CANCELLED',
      })
    end

    it 'cancels the order', :aggregate_failures do
      expect { subject }.to change { order.reload.status }.
        from('ORDER_RECEIVED').to('ORDER_CANCELLED')
      expect(subject).to have_http_status(:ok)
      expect(subject.parsed_body).to include(expected_body)
    end
  end
end
