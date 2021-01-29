class Order < ApplicationRecord
  MAX_NUMBER_OF_RECIPIENTS = 20
  STATUSES = %w[ORDER_RECEIVED ORDER_PROCESSING ORDER_SHIPPED ORDER_CANCELLED].freeze
  GIFTS = %w[MUG T_SHIRT HOODIE STICKER]

  Error = Class.new(StandardError)
  Invalid = Class.new(StandardError)

  belongs_to :school
  has_and_belongs_to_many :recipients

  before_save :validate_order

  def ship
    raise Order::Error, 'Cannot ship a cancelled order' if self.status == 'ORDER_CANCELLED'
    self.update!(status: 'ORDER_SHIPPED')
    email if self.send_email
  end

  def cancel
    raise Order::Error, 'Cannot cancel a shipped order' if self.status == 'ORDER_SHIPPED'
    self.update!(status: 'ORDER_CANCELLED')
  end

private
  def max_gifts_per_day_exceeded?
    todays_orders = school.active_orders_for(Time.zone.now.all_day)
    total_ordered_gifts = todays_orders.inject(0) { |m, o| m += (o.gifts.size * o.recipients.size) }
    total_ordered_gifts > School::MAX_NUMBER_OF_GIFTS_PER_DAY
  end

  def email
    self.recipients.each { |r| GiftsNotifierMailer.send_gift_notification_email(r).deliver_later }
  end

  def validate_order
    raise Order::Invalid unless STATUSES.include?(self.status)
    raise Order::Invalid unless (self.gifts - GIFTS).empty?
    raise Order::Invalid, 'Order should contain at least one recipient' if self.recipients.size < 1
    raise Order::Invalid, 'Order should contain at least one gift' if self.gifts.size < 1
    raise Order::Error, 'Maximum number of recipients exceeded' if self.recipients.size > MAX_NUMBER_OF_RECIPIENTS
    raise Order::Error, 'Maximum number of gifts exceeded for today' if max_gifts_per_day_exceeded?
  end
end
