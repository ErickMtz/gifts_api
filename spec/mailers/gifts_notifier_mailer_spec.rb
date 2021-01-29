require "rails_helper"

RSpec.describe GiftsNotifierMailer, type: :mailer do
  describe "send_gift_notification_email" do
    let(:mail) { GiftsNotifierMailer.send_gift_notification_email(recipient) }
    let(:recipient) { FactoryBot.create :recipient }

    it 'renders the headers' do
      expect(mail.subject).to eq('Your gift is on the way')
      expect(mail.to).to eq([recipient.email])
      expect(mail.from).to eq(['example@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(recipient.name)
      expect(mail.body.encoded).to include(recipient.address)
    end
  end
end
