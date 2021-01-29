require 'rails_helper'

RSpec.describe School, type: :model do
  describe 'associations' do
    it { should have_many(:recipients).dependent(:delete_all) }
    it { should have_many(:orders).dependent(:delete_all) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe '#active_orders_for' do
    subject { school.active_orders_for(Time.zone.now.all_day) }
    let(:school) { FactoryBot.create :school }
    let!(:today_orders) { FactoryBot.create_list :order, 3, :received, school: school }
    let!(:today_cancelled_orders) { FactoryBot.create_list :order, 3, :cancelled, school: school }
    let!(:yesterday_orders) do
      FactoryBot.create_list :order, 2, :received, school: school, created_at: Time.zone.yesterday
    end
    let!(:yesterday_cancelled_orders) do
      FactoryBot.create_list :order, 2, :cancelled, school: school, created_at: Time.zone.yesterday
    end

    it { is_expected.to eq(today_orders) }
  end
end
