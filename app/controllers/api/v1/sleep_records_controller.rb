class Api::V1::SleepRecordsController < ApplicationController
  before_action :authorize_policy, only: [:create]
  def create
    sleep_record = SleepRecordService.create(current_user[:user_id], create_params)
    render json: sleep_record, 
           adapter: :json_api, 
           status: :created, 
           meta: build_meta.merge!({http_status: GoodNightBackend::Constants::STATUS_CODE[:created]})
  rescue Pundit::NotAuthorizedError => e
    GoodNightBackend::Logger.error({
      tags: ['create_sleep_record', 'controller', 'not_authorized'],
      message: "Failed to create sleep record: #{e.message}",
      backtrace: error.backtrace.take(GoodNightBackend::Constants::MAX_BACKTRACE_LENGTH),
    })

    raise GoodNightBackendError::ForbiddenError.new
  end

  private

  def authorize_policy
    authorize SleepRecord
  end

  def build_meta
    {
      message: I18n.t('sleep_record.created_successfully')
    }
  end

  def create_params
    params.require(:sleep_record).permit(:start_time)
  end
end
