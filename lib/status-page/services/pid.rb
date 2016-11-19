module StatusPage
  module Services
    class PidException < StandardError; end

    class Pid < Base
      class Configuration
        attr_accessor :files, :pid

        def initialize
          @files = []
          @pid = nil
        end
      end

      class << self
        def config_class
          Pid::Configuration
        end
      end

      def check!
        check_pid_files!
        check_pid!(config.pid) unless config.pid.nil?
      rescue Exception => e
        raise PidException.new(e.message)
      end

      private

      def check_pid_files!
        return if config.files.blank?
        files = config.files
        files = [config.files] unless config.files.is_a?(Array)

        files.each do |pid_file|
          file_pid = File.read(pid_file)
          if file_pid.blank?
            raise PidException.new("PID file #{pid_file} is empty.")
          end

          check_pid!(file_pid.to_i)
        end
      end

      def check_pid!(number)
        begin
          Process.getpgid(number)
          true
        rescue Errno::ESRCH
          raise PidException.new("Process with PID #{number} is not running")
        end
      end
    end
  end
end
