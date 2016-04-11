module StatusPage
  class Configuration
    attr_accessor :error_callback, :basic_auth_credentials, :interval
    attr_reader :providers

    def initialize
      @providers = Set.new
      @interval = 10
    end

    def use(service_name, opts = {})
      require "status-page/services/#{service_name}"
      klass = "StatusPage::Services::#{service_name.capitalize}".constantize
      if klass.respond_to?(:configurable?) && klass.configurable?
        opts.each_key do |key|
          klass.config.send("#{key}=", opts[key])
        end
      end
      add_service(klass)
    end

    def add_custom_service(custom_service_class)
      unless custom_service_class < StatusPage::Services::Base
        raise ArgumentError.new 'custom provider class must implement '\
          'StatusPage::Services::Base'
      end

      add_service(custom_service_class)
    end

    private

    def add_service(provider_class)
      (@providers ||= Set.new) << provider_class

      provider_class
    end
  end
end
