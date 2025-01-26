class Api::V1::UsersController < ApplicationController
  before_action :authorize_policy

  def list_sleep_records_following
    sleep_records, meta = UserService.list_sleep_records_following(current_user[:user_id], list_sleep_records_following_params)
    render json: sleep_records, 
           adapter: :json_api, 
           status: :ok, 
           meta: meta.merge(build_meta(I18n.t('sleep_record.listed_successfully'), GoodNightBackend::Constants::STATUS_CODE[:ok]))
  end

  private

  def authorize_policy
    authorize User
  end

  def list_sleep_records_following_params
    params.permit(:limit, :offset, :start_date, :start_date_condition, :order_by, :order)
  end

  def build_meta(message, status_code)
    {
      message: message,
      status_code: status_code
    }
  end
end

