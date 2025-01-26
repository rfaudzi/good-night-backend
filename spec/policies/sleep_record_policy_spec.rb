require 'rails_helper'
require 'pundit/rspec'

RSpec.describe SleepRecordPolicy, type: :policy do
  let(:user) { {user_id: 1, exp: Time.current.to_i + 1000} }

  subject { described_class }


  permissions :create? do
    it 'allows create sleep record' do
      expect(subject).to permit(user)
    end
  end

  permissions :update? do
    it 'allows update sleep record' do
      expect(subject).to permit(user, SleepRecord.new(user_id: user[:user_id]))
    end
  end

  permissions :list? do
    it 'allows list sleep record' do
      expect(subject).to permit(user)
    end
  end
end
