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
      monitor = provider.new(request: request)
      monitor.check!

      {
        name: provider.service_name,
        message: '',
        status: STATUSES[:ok]
      }
    rescue => e
      config.error_callback.call(e) if config.error_callback

      {
        name: provider.service_name,
        message: e.message,
        status: STATUSES[:error]
      }
    end
  end
end
