require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:sleep_records) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe '#find_by_id' do
    let(:user) { create(:user) }

    context 'when user is found in redis' do
      before do
        allow_any_instance_of(Redis).to receive(:get).and_return(user.to_json)
      end

      it 'returns a user' do
        expect(User).not_to receive(:find_by)
        expect(User.find_by_id(user.id)).to eq(user)
      end
    end

    context 'when user is not found in redis' do
      before do
        allow_any_instance_of(Redis).to receive(:get).and_return(nil)
      end

      it 'returns a user' do
        expect(User).to receive(:find_by).and_return(user)
        expect(User.find_by_id(user.id)).to eq(user)
      end
    end 
  end
end
