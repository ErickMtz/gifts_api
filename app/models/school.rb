class School < ApplicationRecord
  MAX_NUMBER_OF_GIFTS_PER_DAY = 60

  has_many :recipients, dependent: :delete_all
  has_many :orders, dependent: :delete_all

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def active_orders_for(day)
    self.orders.where.not(status: 'ORDER_CANCELLED').where(created_at: day)
  end
end
