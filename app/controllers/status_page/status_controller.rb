module StatusPage
  class StatusController < ActionController::Base
    if Rails.version.starts_with? '3'
      before_filter :authenticate_with_basic_auth
    else
      before_action :authenticate_with_basic_auth
    end

    # GET /status/check
    def check
      res = StatusPage.check(request: request)

      unless StatusPage.configuration.environmet_variables.nil?
        env_vars = [environmet_variables: StatusPage.configuration.environmet_variables]
        res[:results] = env_vars + res[:results]
      end

      self.content_type = Mime[:json]
      self.response_body = ActiveSupport::JSON.encode(res[:results])
    end

    private

    def authenticate_with_basic_auth
      return true unless StatusPage.configuration.basic_auth_credentials

      credentials = StatusPage.configuration.basic_auth_credentials
      authenticate_or_request_with_http_basic do |name, password|
        name == credentials[:username] && password == credentials[:password]
      end
    end
  end
end
