require 'rails_helper'
require 'rake'

RSpec.describe 'auth:generate_token', type: :task do
  let(:rake) { Rake.application }
  let!(:user) { create(:user, name: 'John Doe') }

  before do
    Rake.application.load_rakefile
  end

  after do
    user.destroy
  end

  describe 'auth:generate_token' do
    context 'when user_id is not provided' do
      it 'prints usage message and exits' do
        expect { rake['auth:generate_token'].invoke }.to raise_error(SystemExit)
      end
    end

    context 'when user does not exist' do
      it 'prints user not found message and exits' do
        expect { rake['auth:generate_token'].invoke(999) }.to raise_error(SystemExit)
      end
    end

    context 'when user exists' do
      it 'generates a JWT for the user' do
        expect { rake['auth:generate_token'].invoke(user.id) }.to output(/Generated JWT for user #{user.id}:/).to_stdout
      end
    end
  end
end 