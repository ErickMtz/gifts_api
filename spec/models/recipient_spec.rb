require 'rails_helper'

RSpec.describe Recipient, type: :model do
  describe 'associations' do
    it { should belong_to(:school) }
  end
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:address) }
  end
end
