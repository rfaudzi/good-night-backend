class ApplicationController < ActionController::API
  include Pundit::Authorization

  rescue_from StandardError do |exception|

    case exception
    when GoodNightBackendError::UnauthorizedError
      render_error(exception, GoodNightBackend::Constants::STATUS_CODE[:unauthorized])
    when GoodNightBackendError::UnprocessableEntityError
      render_error(exception, GoodNightBackend::Constants::STATUS_CODE[:unprocessable_entity])
    when GoodNightBackendError::ForbiddenError
      render_error(exception, GoodNightBackend::Constants::STATUS_CODE[:forbidden])
    when GoodNightBackendError::NotFoundError
      render_error(exception, GoodNightBackend::Constants::STATUS_CODE[:not_found])
    when Pundit::NotAuthorizedError
      render_error(GoodNightBackendError::ForbiddenError.new, GoodNightBackend::Constants::STATUS_CODE[:forbidden])
    else
      raise exception if Rails.env.development?

      render_error(GoodNightBackendError::InternalServerError.new, GoodNightBackend::Constants::STATUS_CODE[:internal_server_error])
    end
  end

  before_action :authorize_request

  def current_user
    token   = request.headers['Authorization']
    pattern = /^Bearer /
    token   = token.gsub(pattern, '') if token.match(pattern)

    JsonWebToken.decode(token) || {}
  rescue
    {}
  end


  private

  def authorize_request
    raise GoodNightBackendError::UnauthorizedError.new if !current_user.present? || current_user[:exp] < Time.current.to_i
  end

  def render_error(exception, status)
    render json: { errors: [build_error_response(exception.title, exception.message, exception.code, status)] }, adapter: :json_api, status: status
  end

  def build_error_response(title, detail, code, status)
    {
      title: title,
      detail: detail,
      code: code,
      status: status
    }
  end
end
