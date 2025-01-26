require 'rails_helper'
require 'pundit/rspec'

RSpec.describe FollowPolicy, type: :policy do
  let(:user) { User.new }

  subject { described_class }

  permissions :create? do
    it "allows a user to create a follow" do
      expect(subject).to permit(user, Follow.new)
    end
  end
end
