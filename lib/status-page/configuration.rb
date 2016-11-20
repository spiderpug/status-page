module StatusPage
  class Configuration
    attr_accessor :error_callback, :basic_auth_credentials, :interval
    attr_reader :providers

    def initialize
      @providers = []
      @interval = 10
    end

    def use(service_name, opts = {})
      require "status-page/services/#{service_name}"
      klass = "StatusPage::Services::#{service_name.capitalize}".constantize
      add_service(klass, opts)
    end

    def add_custom_service(custom_service_class, opts = {})
      unless custom_service_class < StatusPage::Services::Base
        raise ArgumentError.new 'custom provider class must implement '\
          'StatusPage::Services::Base'
      end
      add_service(custom_service_class, opts)
    end

    private

    def add_service(provider_class, opts)
      title = opts.delete(:title)
      record_metrics = opts.delete(:record_metrics)
      monitor = provider_class.new(title: title, record_metrics: record_metrics)

      if provider_class.respond_to?(:configurable?) && provider_class.configurable?
        opts.each_key do |key|
          monitor.config.send("#{key}=", opts[key])
        end
      end
      @providers << monitor

      monitor
    end
  end
end
