module SleepRecordService
  class TrackSleep
    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def call
      if sleep_record.present?
        update_sleep_record(sleep_record)
      else
        create_sleep_record
      end
    rescue StandardError => e
      log_error(e)
      raise
    end

    private

    def sleep_record
      @sleep_record ||= find_latest_open_sleep_record
    end

    def find_latest_open_sleep_record
      latest_record = SleepRecord.where(user_id: user_id)
                                .order(start_time: :desc)
                                .first
      
      return nil if latest_record&.end_time.present?
      latest_record
    end

    def create_sleep_record
      SleepRecord.create!(
        user_id: user_id,
        start_time: Time.current
      )
    end

    def update_sleep_record(record)
      current_time = Time.current
      duration = calculate_duration(record.start_time, current_time)
      
      record.update!(
        end_time: current_time,
        duration: duration
      )
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
