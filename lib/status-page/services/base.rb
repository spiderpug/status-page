module StatusPage
  module Services
    class Base
      attr_reader :request
      attr_reader :config

      def initialize(request: nil, title: nil, record_metrics: true)
        @config = nil
        @request = request
        @title = title
        @record_metrics = true
        @record_metrics = record_metrics unless record_metrics.nil?
      end

      def set_request(request)
        @request = request
      end

      def service_name
        @title || self.class.name.demodulize
      end

      # @abstract
      def check!
        raise NotImplementedError
      end

      def config
        return nil if !self.class.configurable?
        @config ||= self.class.config_class.new
      end

      def self.configurable?
        config_class
      end

      # @abstract
      def self.config_class
      end
    end
  end
end
