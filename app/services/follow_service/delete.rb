module FollowService
  class Delete
    def initialize(user_id, following_id)
      @user_id = user_id
      @following_id = following_id
    end

    def call
      validate_params
      delete_follow
    rescue StandardError => e
      log_error(e)
      raise e
    end

    private

    def validate_params
      raise GoodNightBackendError::BadRequestError.new if @following_id.blank? || @user_id.blank? || @user_id == @following_id
      raise GoodNightBackendError::UnprocessableEntityError.new if @following_id && following_user.blank? || @user_id && user.blank?
      raise GoodNightBackendError::NotFoundError.new if current_record.blank?
    end

    def user
      @user ||= User.find_by(id: @user_id)
    end

    def following_user
      @following_user ||= User.find_by(id: @following_id)
    end

    def current_record
      @current_record ||= Follow.find_by(follower_id: @user_id, following_id: @following_id)
    end

    def delete_follow
      return true if current_record.blank?

      current_record.update!(deleted_at: Time.now)
      true
    end

    def log_error(error)
      GoodNightBackend::Logger.error({
        tags: ['delete', 'error'],
        message: "Failed to delete follow: #{error.message}",
        backtrace: error.backtrace.take(GoodNightBackend::Constants::MAX_BACKTRACE_LENGTH),
        user_id: @user_id
      })
    end
  end
end
