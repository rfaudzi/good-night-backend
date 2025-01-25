module GoodNightBackendError
  class Base < StandardError
    attr_reader :title, :message, :code

    def initialize(title, message, code = 10_000)
      @title = title
      @message = message
      @code = code

      super(message)
    end
  end

  class UnauthorizedError < GoodNightBackendError::Base
    def initialize(title = I18n.t('errors.unauthorized.title'), message = I18n.t('errors.unauthorized.message'), code = 10_001)
      super(title, message, code)
    end
  end

  class UnprocessableEntityError < GoodNightBackendError::Base
    def initialize(title = I18n.t('errors.unprocessable_entity.title'), message = I18n.t('errors.unprocessable_entity.message'), code = 10_002)
      super(title, message, code)
    end
  end

  class ForbiddenError < GoodNightBackendError::Base
    def initialize(title = I18n.t('errors.forbidden.title'), message = I18n.t('errors.forbidden.message'), code = 10_003)
      super(title, message, code)
    end
  end

  class InternalServerError < GoodNightBackendError::Base
    def initialize(title = I18n.t('errors.internal_server_error.title'), message = I18n.t('errors.internal_server_error.message'), code = 10_004)
      super(title, message, code)
    end
  end

  class NotFoundError < GoodNightBackendError::Base
    def initialize(title = I18n.t('errors.not_found.title'), message = I18n.t('errors.not_found.message'), code = 10_005)
      super(title, message, code)
    end
  end
end
