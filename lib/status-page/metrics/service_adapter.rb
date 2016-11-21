module StatusPage
  module Metrics
    module ServiceAdapter
      def initialize(*args)
        super

        @time_series = TimeSeries.new(self)
        start_worker_thread
      end

      attr_reader :time_series

      def stop_metrics_recording!
        @record_metrics = false
      end

      def recording_metrics?
        metrics_enabled_globally? && @record_metrics
      end

      def record_metrics!
        @record_metrics = true
      end

      def record_metric_value(name, value, unit)
        @time_series.record_value(name, value, unit) if recording_metrics?
      end

      def graph_data
        @time_series.data if recording_metrics?
      end

      def check!
        super
      rescue Exception => e
        @time_series.record_error if recording_metrics?
        raise e
      end

      private

      def metrics_enabled_globally?
        StatusPage.config.record_metrics
      end

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
