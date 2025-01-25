require 'rails_helper'

RSpec.describe SleepRecordService::TrackSleep, type: :service do
  let(:user) { create(:user) }

  context 'when there is no open sleep record' do
    it 'creates a new sleep record' do
      expect { described_class.new(user.id).call }.to change(SleepRecord, :count).by(1)
    end
  end

  context 'when there is an open sleep record' do
    it 'updates the existing sleep record' do
      sleep_record = create(:sleep_record, user: user, end_time: nil)
      expect { described_class.new(user.id).call }.to change(SleepRecord, :count).by(0)
    end
  end

  context 'when there is an error' do
    it 'logs the error' do
      allow(SleepRecord).to receive(:create!).and_raise(StandardError, 'test error')
      expect { described_class.new(user.id).call }.to raise_error(StandardError)
    end
  end
end
