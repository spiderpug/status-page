require 'status-page/services/base'
require 'sidekiq/api'

module StatusPage
  module Services
    class SidekiqException < StandardError; end

    class Sidekiq < Base
      class Configuration
        DEFAULT_LATENCY_TIMEOUT = 30

        attr_accessor :latency

        def initialize
          @latency = DEFAULT_LATENCY_TIMEOUT
        end
      end

      def check!
        check_workers!
        check_latency!
        check_redis!
      rescue Exception => e
        raise SidekiqException.new(e.message)
      end

      private

      class << self
        private

        def configuration_class
          Configuration
        end
      end

      def check_workers!
        sidekiq_stats = ::Sidekiq::Stats.new
        if sidekiq_stats.processes_size == 0
          raise "Sidekiq alive processes is 0."
        end
      end

      def check_latency!
        latency = ::Sidekiq::Queue.new.latency

        return unless latency > configuration.latency

        raise "latency #{latency} is greater than #{configuration.latency}"
      end

      def check_redis!
        ::Sidekiq.redis(&:info)
      end
    end
  end
end
