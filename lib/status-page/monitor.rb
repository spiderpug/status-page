require 'status-page/configuration'

module StatusPage
  STATUSES = {
    ok: 'OK',
    error: 'ERROR'
  }.freeze

  extend self

  attr_accessor :configuration

  def configure
    self.configuration ||= Configuration.new

    yield configuration if block_given?
  end

  def check(request: nil)
    if configuration.interval > 0
      if @cached_status && @cached_status[:timestamp] >= (configuration.interval || 5).seconds.ago
        return @cached_status
      end
    end

    providers = configuration.providers || []
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
    configuration.error_callback.call(e) if configuration.error_callback

    {
      name: provider.service_name,
      message: e.message,
      status: STATUSES[:error]
    }
  end
end

StatusPage.configure
