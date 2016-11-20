module StatusPage
  module Metrics
    module ServiceAdapter
      def initialize(*args)
        super

        @time_series = TimeSeries.new()
        start_worker_thread
      end

      attr_reader :time_series

      def record_metric_value(name, value, unit)
        @time_series.record_value(name, value, unit)
      end

      def graph_data
        @time_series.data
      end

      def check!
        super
      rescue => e
        @time_series.record_error
        raise e
      end

      private

      def start_worker_thread
        unless defined?(Rails::Console)
          @@update_thread ||= Thread.new do
            while true
              sleep StatusPage.config.interval + 1
              StatusPage.check
            end
          end
        end
      end
    end
  end
end
