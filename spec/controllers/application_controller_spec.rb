require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render json: { message: 'success' }
    end
  end

  let(:user) { create(:user) }

  describe '#current_user' do
    before do
      allow_any_instance_of(Redis).to receive(:get).and_return(nil)
      allow_any_instance_of(Redis).to receive(:set).and_return(true)
    end

    context 'with valid token and user can be found' do
      let(:token) { JsonWebToken.encode(user_id: user.id) }

      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'returns the current user' do
        expect(controller.current_user).to include(:user_id)
      end
    end

    context 'with valid token and user cannot be found' do
      let(:token) { JsonWebToken.encode({user_id: 1}, Time.current.to_i - 1) }

      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'returns an empty hash' do
        expect(controller.current_user).to eq({})
      end
    end

    context 'with invalid token' do
      before do
        request.headers['Authorization'] = ''
      end

      it 'returns an empty hash' do
        expect(controller.current_user).to eq({})
      end
    end

    context 'when token is expired' do
      let(:token) { JsonWebToken.encode({user_id: user.id}, Time.current.to_i - 1) }

      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'returns an empty hash' do
        expect(controller.current_user).to eq({})
      end
    end

    context 'when decoded token is found in redis' do
      let(:token) { JsonWebToken.encode({user_id: user.id}) }
      let(:decoded_token) { JsonWebToken.decode(token) }
      before do
        request.headers['Authorization'] = "Bearer #{token}"
        allow_any_instance_of(Redis).to receive(:get).and_return(decoded_token.to_json)
      end

      it 'returns the current user' do
        expect(controller.current_user).to include(:user_id)
      end
    end

    context 'when decoded token is not found in redis' do
      let(:token) { JsonWebToken.encode({user_id: user.id}) }

      before do
        request.headers['Authorization'] = "Bearer #{token}"
        allow_any_instance_of(Redis).to receive(:get).and_return(nil)
      end

      it 'returns an empty hash' do
        expect_any_instance_of(Redis).to receive(:set)
        expect(controller.current_user).to include(:user_id)
      end
    end
  end

  describe '#authorize_request' do
    context 'when user is not present' do
      it 'raises UnauthorizedError' do
        allow(controller).to receive(:current_user).and_return({})
        expect { controller.send(:authorize_request) }.to raise_error(GoodNightBackendError::UnauthorizedError)
      end
    end

    context 'when user is present but token is expired' do
      it 'raises UnauthorizedError' do
        allow(controller).to receive(:current_user).and_return({ exp: Time.current.to_i - 1 })
        expect { controller.send(:authorize_request) }.to raise_error(GoodNightBackendError::UnauthorizedError)
      end
    end

    context 'when user is present and token is valid' do
      it 'does not raise an error' do
        allow(controller).to receive(:current_user).and_return({ exp: Time.current.to_i + 1 })
        expect { controller.send(:authorize_request) }.not_to raise_error
      end
    end
  end
end 