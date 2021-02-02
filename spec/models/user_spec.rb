require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it do
      should have_many(:access_grants).
        class_name('Doorkeeper::AccessGrant').
        with_foreign_key(:resource_owner_id).
        dependent(:delete_all)
    end
    it do
      should have_many(:access_tokens).
        class_name('Doorkeeper::AccessToken').
        with_foreign_key(:resource_owner_id).
        dependent(:delete_all)
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end
end
