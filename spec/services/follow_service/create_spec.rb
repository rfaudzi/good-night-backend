require 'rails_helper'

RSpec.describe FollowService::Create, type: :service do
  let(:user) { create(:user) }
  let(:following_user) { create(:user) }

  describe '#call' do
    context 'success' do
      context 'when params are valid' do
        it 'creates a new follow' do
          follow = FollowService.create(user.id, following_user.id)
          expect(follow).to be_a(Follow)
        end
      end

      context 'when follow already exists' do
        it 'updates the follow' do
          follow = FollowService.create(user.id, following_user.id)
          expect(follow).to be_a(Follow)
        end
      end
    end

    context 'failure' do
      context 'when user id and following user id are same' do
        it 'raises an error' do
          expect { FollowService.create(user.id, user.id) }.to raise_error(GoodNightBackendError::UnprocessableEntityError)
        end
      end

      context 'when user is not found' do
        before do
          allow(User).to receive(:find_by).with(id: user.id).and_return(nil)
          allow(User).to receive(:find_by).with(id: following_user.id).and_return(following_user)
        end

        it 'raises an error' do
          expect { FollowService.create(user.id, following_user.id) }.to raise_error(GoodNightBackendError::UnprocessableEntityError)
        end
      end

      context 'when following user id is invalid' do
        it 'raises an error' do
          expect { FollowService.create(user.id, nil) }.to raise_error(GoodNightBackendError::BadRequestError)
        end
      end

      context 'when param following user exists but is not a user' do
        it 'raises an error' do
          expect { FollowService.create(user.id, 'not_a_user') }.to raise_error(GoodNightBackendError::UnprocessableEntityError)
        end
      end
    end
  end
end
