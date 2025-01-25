require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_time) }
  end

  describe 'end_time validation' do
    let(:user) { create(:user) }

    context 'when end_time is before start_time' do
      let(:sleep_record) do
        build(:sleep_record,
          user: user,
          start_time: Time.current,
          end_time: 1.hour.ago
        )
      end

      it 'is invalid' do
        expect(sleep_record).to be_invalid
        expect(sleep_record.errors[:end_time]).to include('must be after start time')
      end
    end

    context 'when end_time is after start_time' do
      let(:sleep_record) do
        build(:sleep_record,
          user: user,
          start_time: 1.hour.ago,
          end_time: Time.current
        )
      end

      it 'is valid' do
        expect(sleep_record).to be_valid
      end
    end
  end
end
