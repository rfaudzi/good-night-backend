module GoodNightBackend
  module Constants
    MAX_BACKTRACE_LENGTH = 10
    STATUS_CODE = {
      created: 201,
      ok: 200,
      bad_request: 400,
      unauthorized: 401,
      forbidden: 403,
      not_found: 404,
      unprocessable_entity: 422,
      internal_server_error: 500,
      deleted: 204
    }
  end
end
