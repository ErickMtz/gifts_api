class GiftsNotifierMailer < ApplicationMailer
  default :from => 'example@example.com'

  def send_gift_notification_email(recipient)
    @recipient = recipient
    mail( to: @recipient.email, subject: 'Your gift is on the way' )
  end
end
