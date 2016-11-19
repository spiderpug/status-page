module StatusPage
  module Services
    class Base
      attr_reader :request
      attr_reader :config

      def initialize(request: nil)
        @config = nil
        @request = request
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
