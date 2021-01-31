class User < ApplicationRecord
  has_secure_password

  has_many :access_grants,
    class_name: 'Doorkeeper::AccessGrant',
    foreign_key: :resource_owner_id,
    dependent: :delete_all

  has_many :access_tokens,
    class_name: 'Doorkeeper::AccessToken',
    foreign_key: :resource_owner_id,
    dependent: :delete_all

  validates :email, presence: true, uniqueness: true

  def admin?
    !!self.admin
  end
end
