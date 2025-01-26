class Api::V1::FollowsController < ApplicationController
  before_action :authorize_policy

  def create
    follow = FollowService.create(current_user[:user_id], create_params[:following_id])
    render json: follow, 
           adapter: :json_api, 
           status: :created, 
           meta: build_meta(I18n.t('follow.created_successfully'), GoodNightBackend::Constants::STATUS_CODE[:created])
  end

  private

  def authorize_policy
    authorize Follow
  end

  def create_params
    params.require(:follow).permit(:following_id)
  end

  def build_meta(message, status_code)
    {
      message: message,
      status_code: status_code
    }
  end
end
