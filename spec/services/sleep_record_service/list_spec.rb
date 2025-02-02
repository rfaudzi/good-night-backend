require 'rails_helper'

RSpec.describe SleepRecordService::List, type: :service do
  let(:user) { create(:user) }
  let(:sleep_records) { create_list(:sleep_record, 10, start_time: Time.current - 1.day, user: user) }
  let(:params) do
    {
      user_ids: [user.id],
      limit: 10,
      offset: 0,
      start_date: (Time.current).iso8601,
      start_date_condition: "less_than",
      order_by: "duration",
      order: "desc"
    }
  end

  describe '#call' do
    context 'success' do
      context 'when params are valid' do
        before do
          sleep_records
        end

        it 'returns a list of sleep records' do
          expect_any_instance_of(Redis).to receive(:get).and_return(nil)
          expect_any_instance_of(Redis).to receive(:set).and_return(true)

          result = SleepRecordService.list(params)
          expect(result[0]).to be_a(Array)
          expect(result[1][:total_count]).to eq(10)
          expect(result[1][:limit]).to eq(10)
          expect(result[1][:offset]).to eq(0)
        end
      end

      context 'when user_ids is not present' do
        before do
          params[:user_ids] = []
        end

        it 'returns a list of sleep records' do
          result = SleepRecordService.list(params)
          expect(result[0]).to be_a(Array)
          expect(result[1][:total_count]).to eq(0)
          expect(result[1][:limit]).to eq(10)
          expect(result[1][:offset]).to eq(0)
        end
      end

      context 'when cache data is present' do
        before do
          allow_any_instance_of(Redis).to receive(:get).and_return({data: sleep_records.to_a, total_count: 10}.to_json)
        end

        it 'returns a list of sleep records from cache' do
          result = SleepRecordService.list(params)
          expect(result[0]).to be_a(Array)
          expect(result[1][:total_count]).to eq(10)
          expect(result[1][:limit]).to eq(10)
          expect(result[1][:offset]).to eq(0)
        end
      end
    end

    context 'failure' do
      context 'when start_date_condition is not valid' do
        it 'raises an error' do
          expect { SleepRecordService::List.new(user_ids: [user.id], start_date_condition: "invalid").call }.to raise_error(StandardError)
        end
      end

      context 'when order_by is not valid' do
        it 'raises an error' do
          expect { SleepRecordService::List.new(user_ids: [user.id], order_by: "invalid").call }.to raise_error(StandardError)
        end
      end

      context 'when order is not valid' do
        it 'raises an error' do
          expect { SleepRecordService::List.new(user_ids: [user.id], order: "invalid").call }.to raise_error(StandardError)
        end
      end

      context 'when start_date is not valid' do
        it 'raises an error' do
          expect { SleepRecordService::List.new(user_ids: [user.id], start_date: "invalid").call }.to raise_error(StandardError)
        end
      end
    end
  end
end
