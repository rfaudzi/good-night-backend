module GoodNightBackend
  class Logger
    class << self
      def info(log)
        Rails.logger.info(build_log(log))
      end

      def error(log)
        Rails.logger.error(build_log(log))
      end

      def debug(log)
        Rails.logger.debug(build_log(log))
      end

      def warn(log)
        Rails.logger.warn(build_log(log))
      end

      private

      def build_log(log)
        context_hash.merge(log)
      end

      def context_hash
        RequestStore.store[:context] || {}
      end
    end
  end
end
