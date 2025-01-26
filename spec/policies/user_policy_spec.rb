require 'rails_helper'
require 'pundit/rspec'

RSpec.describe UserPolicy, type: :policy do
  let(:user) { {user_id: 1, exp: Time.current.to_i + 1000} }

  subject { described_class }

  permissions :list_sleep_records_following? do
    it { is_expected.to permit(user, user) }
  end
end
