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

    def initialize(params)
      @params = params
      @limit = params[:limit] || 10
      @offset = params[:offset] || 0
      @start_date = params[:start_date]
      @start_date_condition = params[:start_date_condition] || "greater_than"
      @order_by = params[:order_by] || "start_time"
      @order = params[:order] || "desc"
      @user_ids = params[:user_ids]
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
      raise GoodNightBackendError::BadRequestError.new(message: I18n.t('errors.bad_request.message') + ": user_ids is required") unless @user_ids.present?
      raise GoodNightBackendError::BadRequestError.new(message: I18n.t('errors.bad_request.message') + ": start_date_condition not available") if @start_date_condition && !AVAILABLE_START_DATE_CONDITION.include?(@start_date_condition)
      raise GoodNightBackendError::BadRequestError.new(message: I18n.t('errors.bad_request.message') + ": order_by not available") if @order_by && !AVAILABLE_ORDER_BY.include?(@order_by)
      raise GoodNightBackendError::BadRequestError.new(message: I18n.t('errors.bad_request.message') + ": order not available") if @order && !AVAILABLE_ORDER.include?(@order)
      raise GoodNightBackendError::BadRequestError.new(message: I18n.t('errors.bad_request.message') + ": start_date is not a valid date_time") if @start_date.present? && @start_date.to_datetime.blank?
    end

    def sleep_records
      query_result = SleepRecord.where(user_id: @params[:user_ids])

      if @start_date.present?
        condition = AVAILABLE_START_DATE_CONDITION[@start_date_condition]
        query_result = query_result.where("start_time #{condition} ?", @start_date.to_datetime.utc)
      end
      total_count = query_result.count

      query_result.order(@order_by => @order).limit(@limit).offset(@offset)

      [query_result.to_a, build_meta(total_count)]
    end

    def build_meta(total_count)
      {
        total_count: total_count,
        limit: @limit,
        offset: @offset
      }
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
