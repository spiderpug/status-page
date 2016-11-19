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

      class << self
        def config_class
          Delayedjob::Configuration
        end
      end

      def delayed_job
        Delayed::Job
      end

      def check!
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

      def check_failed_jobs!
        failed_jobs = delayed_job.where('last_error IS NOT NULL').count

        if failed_jobs > 0
          raise DelayedJobException.new("#{failed_jobs} jobs failed.")
        end
      end
    end
  end
end

