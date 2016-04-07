module StatusPage
  class Configuration
    PROVIDERS = [:cache, :database, :redis, :resque, :sidekiq].freeze

    attr_accessor :error_callback, :basic_auth_credentials, :interval
    attr_reader :providers

    def initialize
      @providers = Set.new
      @interval = 10
    end

    def use(service_name)
      require "status-page/services/#{service_name}"
      add_service("StatusPage::Services::#{service_name.capitalize}".constantize)
    end

    PROVIDERS.each do |service_name|
      define_method service_name do |&_block|
        require "status-page/services/#{service_name}"

        add_service("StatusPage::Services::#{service_name.capitalize}".constantize)
      end
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
