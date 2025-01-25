require 'rails_helper'

RSpec.describe SleepRecordService::Update, type: :service do
  let!(:user) { create(:user) }

  describe '#call' do
    context 'success' do
      context 'when sleep record exists' do
        let(:start_time) { Time.new(2025, 1, 1, 12, 0, 0).utc }
        let(:end_time) { start_time + 2.hours }
        let(:end_time_params) { '2025-01-01T07:00:00Z' }
        let!(:sleep_record) { create(:sleep_record, user: user, start_time: start_time, end_time: nil) }

        before do
          allow(Time).to receive(:current).and_return(end_time)
        end

        it 'updates the sleep record' do
          expect { SleepRecordService.update(user.id, sleep_record, { end_time: end_time_params }) }.not_to raise_error
          expect(sleep_record.reload.end_time).to eq(end_time)
          expect(sleep_record.duration).to eq(2.hour / 60)
        end
      end
    end

    context 'failure' do
      let(:start_time) { Time.new(2025, 1, 1, 12, 0, 0) }
      let!(:sleep_record) { create(:sleep_record, user: user, start_time: start_time, end_time: nil) }

      context 'when user id is invalid' do
        it 'raises an error' do
          expect { SleepRecordService.update(nil, sleep_record, { end_time: end_time }) }.to raise_error(StandardError)
        end
      end

      context 'when user id is not found' do
        it 'raises an error' do
          expect { SleepRecordService.update(user.id + 1, sleep_record, { end_time: end_time }) }.to raise_error(StandardError)
        end
      end

      context 'when sleep record is not found' do
        it 'raises an error' do
          expect { SleepRecordService.update(user.id, nil, { end_time: end_time }) }.to raise_error(StandardError)
        end
      end

      context 'when sleep record is already ended' do
        it 'raises an error' do
          expect { SleepRecordService.update(user.id, sleep_record, { end_time: end_time }) }.to raise_error(StandardError)
        end
      end
    end
  end
end
