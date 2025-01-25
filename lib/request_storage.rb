module RequestStorage
  class Context
    attr_accessor :request_id, :track_id, :user_id

    def initialize(current_user = {})
      @request_id = SecureRandom.uuid
      @user_id = current_user[:id]
      @track_id = @user_id
    end

    def common_info
      {
        request_id: request_id,
        track_id: track_id,
        user_id: user_id
      }
    end
  end

  def self.create_context(current_user = {})
    context = Context.new(current_user)
    RequestStore.store[:request_context] = context
    context
  end

  def self.context
    RequestStore.store[:request_context] || create_context
  end
end
