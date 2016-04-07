module StatusPage
  module Services
    class Base
      attr_reader :request
      cattr_accessor :config

      def self.service_name
        @name ||= name.demodulize
      end

      def self.configure
        return unless configurable?

        self.config ||= config_class.new

        yield self.config if block_given?
      end

      def initialize(request: nil)
        @request = request

        self.class.configure
      end

      # @abstract
      def check!
        raise NotImplementedError
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
