module FollowService
  class Create
    def initialize(user_id, following_id)
      @user_id = user_id
      @following_id = following_id
    end

    def call
      validate_params
      create_follow
    rescue StandardError => e
      log_error(e)
      raise e
    end

    private

    def validate_params
      raise GoodNightBackendError::BadRequestError.new if @following_id.blank? || @user_id.blank?
      raise GoodNightBackendError::UnprocessableEntityError.new if @user_id == @following_id
      raise GoodNightBackendError::UnprocessableEntityError.new if @following_id && following_user.blank? || @user_id && user.blank?
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

    def create_follow
      if current_record.present?
        current_record.update!(deleted_at: nil)
      else
        Follow.create!(
          follower_id: @user_id,
          following_id: @following_id
        )
      end
    end

    def log_error(error)
      GoodNightBackend::Logger.error({
        tags: ['create', 'error'],
        message: "Failed to create follow: #{error.message}",
        backtrace: error.backtrace.take(GoodNightBackend::Constants::MAX_BACKTRACE_LENGTH),
        user_id: @user_id
      })
    end
  end
end
