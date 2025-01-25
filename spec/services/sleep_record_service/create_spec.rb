require 'rails_helper'

RSpec.describe SleepRecordService::Create, type: :service do
  let(:user) { create(:user) }

  after do
    user.destroy
  end

  describe '#call' do
    context 'success' do
      context 'when params are valid' do
        it 'creates a new sleep record' do
          sleep_record = SleepRecordService.create(user.id, { start_time: Time.current })
          expect(sleep_record).to be_a(SleepRecord)
          expect(sleep_record.user_id).to eq(user.id)
          expect(sleep_record.start_time).to be_present

          sleep_record.destroy
        end
      end
    end

    context 'failure' do
      context 'when user id is invalid' do
        it 'raises an error' do
          expect { SleepRecordService.create(nil, { start_time: Time.current }) }.to raise_error(StandardError)
        end
      end
  
      context 'when user is not found' do
        it 'raises an error' do
          expect { SleepRecordService.create(user.id + 1, { start_time: Time.current }) }.to raise_error(StandardError)
        end
      end
  
      context 'when params are invalid' do
        it 'raises an error' do
          expect { SleepRecordService.create(user.id, nil) }.to raise_error(StandardError)
        end
      end

      context 'when params start time is invalid' do
        it 'raises an error' do
          expect { SleepRecordService.create(user.id, { start_time: 'invalid' }) }.to raise_error(StandardError)
        end
      end

      context 'when params start time is blank' do
        it 'raises an error' do
          expect { SleepRecordService.create(user.id, { start_time: '' }) }.to raise_error(StandardError)
        end
      end
    end
  end
end
