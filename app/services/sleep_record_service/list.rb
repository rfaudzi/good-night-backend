module SleepRecordService
  class List
    attr_reader :params, :limit, :offset, :start_date, :start_date_condition, :order_by, :order

    AVAILABLE_ORDER_BY = ["start_time", "duration"]
    AVAILABLE_ORDER = ["asc", "desc"]
    AVAILABLE_START_DATE_CONDITION = {
      "less_than" => "<",
      "greater_than" => ">",
      "equal" => "=",
      "not_equal" => "!="
    }
    MAX_LIMIT_RECORDS = 100

    def initialize(params)
      @params = params
      @limit = params[:limit] || 10
      @offset = params[:offset] || 0
      @start_date = params[:start_date]
      @start_date_condition = params[:start_date_condition] || "greater_than"
      @order_by = params[:order_by] || "start_time"
      @order = params[:order] || "desc"
      @user_ids = params[:user_ids]
      @closed_records = params[:closed_records]
      @limit = [@limit.to_i, MAX_LIMIT_RECORDS].min
    end

    def call
      validate_params
      sleep_records
    rescue StandardError => e
      log_error(e)
      raise e
    end

    private

    def validate_params
      title = I18n.t('errors.bad_request.title')
      message = I18n.t('errors.bad_request.message')

      raise GoodNightBackendError::BadRequestError.new(title, message + ": start_date_condition not available") if @start_date_condition && !AVAILABLE_START_DATE_CONDITION.include?(@start_date_condition)
      raise GoodNightBackendError::BadRequestError.new(title, message + ": order_by not available") if @order_by && !AVAILABLE_ORDER_BY.include?(@order_by)
      raise GoodNightBackendError::BadRequestError.new(title, message + ": order not available") if @order && !AVAILABLE_ORDER.include?(@order)
      raise GoodNightBackendError::BadRequestError.new(title, message + ": start_date is not a valid date_time") if @start_date.present? && @start_date.to_datetime.blank?
    end

    def sleep_records
      return [[], build_meta(0)] if @user_ids.blank?

      cache_key = build_cache_key
      cached_result = REDIS.get(cache_key)
      if cached_result.present?
        parsed_cached_result = JSON.parse(cached_result).with_indifferent_access
        return [SleepRecord.to_list_objects(parsed_cached_result[:data]), build_meta(parsed_cached_result[:total_count])]
      end

      query_result = SleepRecord.where(user_id: @user_ids)

      if @start_date.present?
        condition = AVAILABLE_START_DATE_CONDITION[@start_date_condition]
        query_result = query_result.where("start_time #{condition} ?", @start_date.to_datetime.utc)
      end

      if @closed_records
        query_result = query_result.where("duration > 0")
      end

      total_count = query_result.count

      result = query_result.order(@order_by => @order).limit(@limit).offset(@offset)

      if result.present?
        data_cache = {
          total_count: result.count,
          data: result.to_a
        }
        REDIS.set(cache_key, data_cache.to_json, ex: 1.hour)
      end

      [result.to_a, build_meta(total_count)]
    end

    def build_meta(total_count)
      {
        total_count: total_count.to_i,
        limit: @limit.to_i,
        offset: @offset.to_i
      }
    end

    def build_cache_key
     "sleep_records:list:#{@user_ids.sort.join(',')}:#{@start_date || '_'}:#{@start_date_condition}:#{@closed_records}:#{@order_by}:#{@order}:#{@limit}:#{@offset}"
    end

    def log_error(error)
      GoodNightBackend::Logger.error({
        tags: ['list', 'error'],
        message: "Failed to list sleep records: #{error.message}",
        backtrace: error.backtrace.take(GoodNightBackend::Constants::MAX_BACKTRACE_LENGTH),
        user_id: @params[:user_ids]
      })
    end
  end
end
