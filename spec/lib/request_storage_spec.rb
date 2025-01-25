require 'rails_helper'

RSpec.describe RequestStorage, type: :lib do
  it 'has a context' do
    expect(RequestStorage.context).to be_a(RequestStorage::Context)
  end

  context 'with current user' do
    let(:current_user) { { id: 123, name: 'John Doe' } }

    it 'creates context with current user data' do
      context = RequestStorage.create_context(current_user)
      
      expect(context.user_id).to eq(123)
      expect(context.track_id).to eq(123)
      expect(context.request_id).not_to be_nil
    end
  end

  context 'without current user' do
    it 'creates context with default user data' do
      context = RequestStorage.create_context
      expect(context.user_id).to eq(nil)
      expect(context.track_id).to eq(nil)
      expect(context.request_id).not_to be_nil
    end
  end
end
