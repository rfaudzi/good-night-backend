require 'rails_helper'
require 'pundit/rspec'

RSpec.describe SleepRecordPolicy, type: :policy do
  let(:user) { User.new(id: 1) }

  subject { described_class }

  permissions :create? do
    it 'allows create sleep record' do
      expect(subject).to permit(user)
    end
  end
end
