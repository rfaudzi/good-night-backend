module SleepRecordService
  class Update < Base
    attr_reader :sleep_record, :params
    def initialize(user_id,sleep_record, params)
      super(user_id)
      @sleep_record = sleep_record
      @params = params
    end

    def call
      validate_user_id
      validate_params
      update_sleep_record
    rescue StandardError => e
      log_error(e)
      raise
    end

    private

    def validate_params
      raise GoodNightBackendError::NotFoundError.new unless sleep_record
      raise GoodNightBackendError::UnprocessableEntityError.new if sleep_record.end_time.present? || !valid_params?
    end

    def valid_params?
      params.present? && 
      params[:end_time].present? && 
      valid_end_time?
    end

    def valid_end_time?
      begin
        end_time = params[:end_time].to_datetime.utc
        end_time >= sleep_record.start_time
      rescue ArgumentError
        false
      end
    end

    def update_sleep_record
      end_time = params[:end_time].to_datetime.utc
      duration = calculate_duration(sleep_record.start_time, end_time)

      sleep_record.update!(
        end_time: end_time,
        duration: duration
      )

      sleep_record
    end

    def calculate_duration(start_time, end_time)
      ((end_time - start_time) / 60).to_i # in minutes
    end

    def log_error(error)
      GoodNightBackend::Logger.error({
        tags: ['track_sleep', 'error'],
        message: "Failed to track sleep record: #{error.message}",
        backtrace: error.backtrace.take(GoodNightBackend::Constants::MAX_BACKTRACE_LENGTH),
        user_id: user_id
      })
    end
  end
end
