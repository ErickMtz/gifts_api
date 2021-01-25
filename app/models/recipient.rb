class Recipient < ApplicationRecord
  belongs_to :school

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :address, presence: true
end
