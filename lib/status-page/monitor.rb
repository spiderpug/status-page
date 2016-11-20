module StatusPage
  STATUSES = {
    ok: 'OK',
    error: 'ERROR'
  }.freeze

  class << self
    def config
      return @config if defined?(@config)
      @config = Configuration.new
      @config
    end

    def configure(&block)
      config.instance_exec(&block)
    end

    def check(request: nil)
      if config.interval > 0
        if @cached_status && @cached_status[:timestamp] >= (config.interval || 5).seconds.ago
          return @cached_status
        end
      end

      providers = config.providers || []
      results = providers.map { |provider| provider_result(provider, request) }

      @cached_status = {
        results: results,
        status: results.all? { |result| result[:status] == STATUSES[:ok] } ? :ok : :service_unavailable,
        timestamp: Time.now
      }
      @cached_status
    end

    private

    def provider_result(provider, request)
      provider.set_request(request)

      data = {
        name: provider.service_name,
        status: STATUSES[:ok],
      }

      begin
        message = provider.check!
        data[:message] = message
      rescue => e
        config.error_callback.call(e) if config.error_callback

        data.merge!({
          message: e.message,
          status: STATUSES[:error]
        })
      end

      if provider.respond_to?(:graph_data)
        data.merge!(graph_data: provider.graph_data)
      end

      data
    end
  end
end
