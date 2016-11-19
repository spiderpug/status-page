require 'typhoeus'
if defined?(Faraday)
  require 'typhoeus/adapters/faraday'
end

module StatusPage
  module Services
    class HttpException < StandardError; end

    class Http < Base
      class Configuration
        attr_accessor :url, :method, :params, :body, :headers, :request_options,

          :response_expectation # block, string or regex

        def initialize
          @url = nil
          @method = :get
          @params = {}
          @body = nil
          @headers = {}
          @request_options = {}
          @response_expectation = nil
        end
      end

      class << self
        def config_class
          Http::Configuration
        end
      end

      def check!
        response = Typhoeus.send(config.method, config.url, {
          body: config.body,
          params: config.params,
          headers: config.headers,
        }.reverse_merge(config.request_options))

        if response.success?
          # metrics:
          # response.time # total time of request
          # response.connect_time # time to connect
          # response.starttransfer_time # time to first byte
          check_response_expectation!(response)

          "#{response.time} ms"
        elsif response.timed_out?
          raise HttpException.new("Request timeout")
        elsif response.code == 0
          raise HttpException.new(response.return_message)
        else
          raise HttpException.new("HTTP request failed: " + response.code.to_s)
        end
      end

      private

      def check_response_expectation!(response)
        return if config.response_expectation.blank?

        expectation = config.response_expectation
        if expectation.respond_to?(:call)
          self.instance_exec(response, &expectation)
        elsif expectation.is_a?(String)
          raise HttpException.new("Response does not contain #{expectation}") unless response.body.include?(expectation)
        elsif expectation.is_a?(Regexp)
          raise HttpException.new("Response does not match #{expectation}") unless response.body.match(expectation)
        else
          raise HttpException.new("Could not process body expectation: #{expectation}")
        end
      end
    end
  end
end
