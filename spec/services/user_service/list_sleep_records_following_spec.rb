require 'rails_helper'

RSpec.describe UserService::ListSleepRecordsFollowing, type: :service do
  let(:user) { create(:user) }
  let(:following_user) { create(:user) }
  let(:following) { create(:follow, follower_id: user.id, following_id: following_user.id) }
  let(:sleep_records_following) { create_list(:sleep_record, 9, start_time: Time.current - 1.day, user: following_user) }
  let(:params) do
    {
      user_id: user.id,
      limit: 10,
      offset: 0,
      start_date: 1.week.ago.beginning_of_day,
      start_date_condition: 'greater_than',
      order_by: 'duration',
      order: 'desc'
    }
  end

  before do
    following
    sleep_records_following
  end

  describe '#call' do
    context 'success' do
      before do
        following
        sleep_records_following
      end

      it 'returns a list of sleep records' do
        result, meta = UserService.list_sleep_records_following(user.id,params)
        expect(result).to be_a(Array)
        expect(meta[:total_count]).to eq(9)
        expect(meta[:limit]).to eq(10)
        expect(meta[:offset]).to eq(0)
      end
    end

    context 'failure' do
      context 'when user not found' do
        it 'raises an error' do
          expect { UserService.list_sleep_records_following(user.id + 100, params) }.to raise_error(GoodNightBackendError::UnprocessableEntityError)
        end
      end
    end
  end
end
