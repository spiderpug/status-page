module StatusPage
  module Services
    class DelayedJobException < StandardError; end

    class Delayedjob < Base
      class Configuration
        attr_accessor :pid_files

        def initialize
          @pid_files = []
        end
      end

      prepend Metrics::ServiceAdapter

      class << self
        def config_class
          Delayedjob::Configuration
        end
      end

      def delayed_job
        Delayed::Job
      end

      def check!
        record_metrics

        check_running_workers!
        check_failed_jobs!
      rescue Exception => e
        raise DelayedJobException.new(e.message)
      end

      private

      def check_running_workers!
        if config.pid_files
          pid_checker = Pid.new(request: request)
          pid_checker.config.files = config.pid_files
          pid_checker.check!
        end
      end

      def record_metrics
        record_metric_value('pending jobs', pending_job_count, '')
        record_metric_value('failed jobs', failed_job_count, '')
      end

      def pending_job_count
        delayed_job.where(attempts: 0, locked_at: nil).count
      end

      def failed_job_count
        delayed_job.where('last_error IS NOT NULL').count
      end

      def check_failed_jobs!
        if failed_job_count > 0
          raise DelayedJobException.new("#{failed_jobs} jobs failed.")
        end
      end
    end
  end
end

