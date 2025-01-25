class Api::V1::SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: [:update]
  before_action :authorize_policy, only: [:create, :update]

  def create
    sleep_record = SleepRecordService.create(current_user[:user_id], create_params)
    render json: sleep_record, 
           adapter: :json_api, 
           status: :created, 
           meta: build_meta(I18n.t('sleep_record.created_successfully'), GoodNightBackend::Constants::STATUS_CODE[:created])
  rescue Pundit::NotAuthorizedError => e
    GoodNightBackend::Logger.error({
      tags: ['create_sleep_record', 'controller', 'not_authorized'],
      message: "Failed to create sleep record: #{e.message}",
      backtrace: error.backtrace.take(GoodNightBackend::Constants::MAX_BACKTRACE_LENGTH),
    })

    raise GoodNightBackendError::ForbiddenError.new
  end

  def update
    sleep_record = SleepRecordService.update(current_user[:user_id], @sleep_record, update_params)
    render json: sleep_record, 
           adapter: :json_api, 
           status: :ok, 
           meta: build_meta(I18n.t('sleep_record.updated_successfully'), GoodNightBackend::Constants::STATUS_CODE[:ok])
  rescue Pundit::NotAuthorizedError => e
    GoodNightBackend::Logger.error({
      tags: ['update_sleep_record', 'controller', 'not_authorized'],
      message: "Failed to update sleep record: #{e.message}",
      backtrace: error.backtrace.take(GoodNightBackend::Constants::MAX_BACKTRACE_LENGTH),
    })

    raise GoodNightBackendError::ForbiddenError.new
  end

  private

  def authorize_policy

    case action_name
    when 'create'
      authorize SleepRecord.new
    when 'update'
      authorize @sleep_record
    end
  end

  def build_meta(message, http_status)
    {
      message: message,
      http_status: http_status
    }
  end

  def update_params
    params.require(:sleep_record).permit(:end_time, :id)
  end

  def create_params
    params.require(:sleep_record).permit(:start_time)
  end

  def set_sleep_record
    @sleep_record = SleepRecord.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise GoodNightBackendError::NotFoundError.new
  end
end
