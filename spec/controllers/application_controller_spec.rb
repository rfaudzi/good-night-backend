require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render json: { message: 'success' }
    end
  end

  describe '#current_user' do
    context 'with valid token' do
      let(:token) { JsonWebToken.encode(user_id: 1) }

      before do
        request.headers['Authorization'] = "Bearer #{token}"
      end

      it 'returns the current user' do
        expect(controller.current_user).to include(:user_id)
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