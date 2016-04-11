module StatusPage
  module Services
    class Base
      attr_reader :request

      def initialize(request: nil)
        @request = request
      end

      def self.service_name
        @name ||= name.demodulize
      end

      # @abstract
      def check!
        raise NotImplementedError
      end

      def self.config
        return nil if !self.configurable?
        @config ||= config_class.new
      end

      def config
        self.class.config
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
