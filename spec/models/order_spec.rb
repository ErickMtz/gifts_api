require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:school) }
    it do
      expect(described_class.reflect_on_association(:recipients).join_table).
        to eq('orders_recipients')
    end
  end

  describe 'before_save' do
    subject { order.save! }

    let(:school) { FactoryBot.create :school }
    let(:order) { FactoryBot.build :order, :received, school: school, recipients: recipients }

    context 'without recipients' do
      let(:recipients) { [] }

      it { expect { subject }.to raise_error(Order::Invalid) }
    end

    context 'max number of recipients exceeded' do
      let(:recipients) do
        FactoryBot.create_list :recipient, Order::MAX_NUMBER_OF_RECIPIENTS + 1, school: school
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Order::Error)
      end
    end
  end

  describe '#ship' do
    subject { order.ship }

    let(:order) { FactoryBot.create :order, status: status, send_email: send_email }
    let(:status) { 'ORDER_RECEIVED' }
    let(:send_email) { false }

    it do
      expect { subject }.to change{ order.reload.status }.
        from('ORDER_RECEIVED').to('ORDER_SHIPPED')
    end

    context 'cancelled order' do
      let(:status) { 'ORDER_CANCELLED' }

      it 'raises an error' do
        expect { subject }.to raise_error(Order::Error, 'Cannot ship a cancelled order')
      end
    end

    context 'send email' do
      let(:send_email) { true }
      before { ActiveJob::Base.queue_adapter = :test }

      it 'sends a notification email' do
        subject
        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.size).to eq(1)
        expect(ActionMailer::MailDeliveryJob).to(
          have_been_enqueued.with do |class_name, action, delivery_method, params|
            expect(class_name).to eq('GiftsNotifierMailer')
            expect(action).to eq('send_gift_notification_email')
            expect(delivery_method).to eq('deliver_now') # always deliver_now in test
            expect(params).to include(args: [order.recipients.first])
          end
        )
      end
    end
  end

  describe '#cancel' do
    subject { order.cancel }

    let(:order) { FactoryBot.create :order, status: status }
    let(:status) { 'ORDER_RECEIVED' }

    it do
      expect { subject }.to change{ order.reload.status }.
        from('ORDER_RECEIVED').to('ORDER_CANCELLED')
    end

    context 'shipped order' do
      let(:status) { 'ORDER_SHIPPED' }

      it 'raises an error' do
        expect { subject }.to raise_error(Order::Error, 'Cannot cancel a shipped order')
      end
    end
  end
end
