require 'rails_helper'

RSpec.describe FollowService::Delete, type: :service do
  let(:user) { create(:user) }
  let(:following_user) { create(:user) }

  describe '#call' do
    context 'success' do
      context 'when params are valid' do
        it 'deletes the follow' do
          expect(FollowService.delete(user.id, following_user.id)).to be_truthy
        end
      end

      context 'when current record is not found' do
        it 'does not raise an error' do
          expect(FollowService.delete(user.id, following_user.id)).to be_truthy
        end
      end
    end

    context 'failure' do
      context 'when user id is invalid' do
        it 'raises an error' do
          expect { FollowService.delete(nil, following_user.id) }.to raise_error(StandardError)
        end
      end

      context 'when user is not found' do
        before do
          allow(User).to receive(:find_by).with(id: user.id).and_return(nil)
          allow(User).to receive(:find_by).with(id: following_user.id).and_return(following_user)
        end

        it 'raises an error' do
          expect { FollowService.delete(user.id, following_user.id) }.to raise_error(StandardError)
        end
      end

      context 'when following user id is invalid' do
        it 'raises an error' do
          expect { FollowService.delete(user.id, nil) }.to raise_error(StandardError)
        end
      end

      context 'when following user is not found' do
        it 'raises an error' do
          expect { FollowService.delete(user.id, 'not_a_user') }.to raise_error(StandardError)
        end
      end
    end
  end
end

