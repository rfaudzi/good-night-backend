module UserService
  class ListSleepRecordsFollowing
    attr_reader :user_id, :params, :limit, :offset
    def initialize(user_id, params)
      @user_id = user_id
      @params = params
      @limit = params[:limit] || 10
      @offset = params[:offset] || 0
      @start_date = params[:start_date] || 1.week.ago.beginning_of_day
      @start_date_condition = params[:start_date_condition] || "greater_than"
      @order_by = params[:order_by] || "duration"
      @order = params[:order] || "desc"
    end

    def call
      validate_user
      sleep_records_following
    rescue StandardError => e
      log_error(e)

      raise e
    end

    private

    def validate_user
      raise GoodNightBackendError::UnprocessableEntityError.new unless User.exists?(id: @user_id)
    end

    def sleep_records_following
      sleep_record_params = {
        user_ids: following_users.pluck(:following_id),
        start_date: @start_date,
        start_date_condition: @start_date_condition,
        order_by: @order_by,
        order: @order,
        limit: @limit,
        offset: @offset,
        closed_records: true
      }

      SleepRecordService.list(sleep_record_params)
    end

    def following_users
      @following_users ||= Follow.where(follower_id: @user_id, deleted_at: nil)
    end

    def log_error(error)
      GoodNightBackend::Logger.error({
        tags: ['list', 'error'],
        message: "Failed to list sleep records following: #{error.message}",
        backtrace: error.backtrace.take(GoodNightBackend::Constants::MAX_BACKTRACE_LENGTH),
        user_id: @user_id
      })
    end
  end
end

