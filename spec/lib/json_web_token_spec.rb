require 'rails_helper'
require 'json_web_token'

RSpec.describe JsonWebToken do
  let(:valid_payload) { { user_id: 1 } }
  let(:secret_key) { ENV['SECRET_KEY_BASE'] }

  describe '.encode' do
    it 'encodes a payload into a JWT token' do
      token = JsonWebToken.encode(valid_payload)
      expect(token).to be_a(String)
      expect(token.split('.').size).to eq(3)
    end

    it 'sets the expiration time in the payload' do
      token = JsonWebToken.encode(valid_payload)
      decoded_payload = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })[0]
      expect(decoded_payload['exp']).to be_present
    end
  end

  describe '.decode' do
    context 'with a valid token' do
      it 'decodes the token and returns the payload' do
        token = JsonWebToken.encode(valid_payload)
        decoded_payload = JsonWebToken.decode(token)
        expect(decoded_payload).to include('user_id' => 1)
      end
    end

    context 'with an invalid token' do
      it 'returns nil' do
        invalid_token = 'invalid.token.string'
        decoded_payload = JsonWebToken.decode(invalid_token)
        expect(decoded_payload).to be_nil
      end
    end

    context 'with an expired token' do
      it 'returns nil' do
        expired_token = JsonWebToken.encode(valid_payload, Time.now - 1.hour)
        decoded_payload = JsonWebToken.decode(expired_token)
        expect(decoded_payload).to be_nil
      end
    end
  end
end 