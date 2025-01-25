module SleepRecordService
  class Base
    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def validate_user_id
      raise 'Invalid user id' unless user_id.present?
      raise 'User not found' unless user.present?
    end

    def user
      @user ||= User.find(user_id)
    end
  end
end
