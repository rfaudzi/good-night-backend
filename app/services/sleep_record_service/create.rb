module SleepRecordService
  class Create < Base
    attr_reader :params

    def initialize(user_id, params)
      @params = params

      super(user_id)
    end

    def call
      validate_user_id
      validate_params
      create_sleep_record
    rescue StandardError => e
      log_error(e)
      raise
    end

    private

    def validate_params
      raise GoodNightBackend::Errors::UnprocessableEntity.new if params.blank? || params[:start_time].blank? || params[:start_time].to_datetime.blank?
    end

    def create_sleep_record
      SleepRecord.create!(
        user_id: user_id,
        start_time: params[:start_time].to_datetime
      )
    end

    def log_error(error)
      GoodNightBackend::Logger.error({
        tags: ['create', 'error'],
        message: "Failed to create sleep record: #{error.message}",
        backtrace: error.backtrace.take(GoodNightBackend::Constants::MAX_BACKTRACE_LENGTH),
        user_id: user_id
      })
    end
  end
end
