module StatusPage
  class StatusController < ActionController::Base
    before_action :authenticate_with_basic_auth

    def index
      @statuses = statuses

      respond_to do |format|
        format.html
        format.json {
          render json: statuses
        }
        format.xml {
          render xml: statuses
        }
      end
    end

    private

    def statuses
      return @statuses if defined? @statuses
      @statuses = StatusPage.check(request: request)
    end

    def authenticate_with_basic_auth
      return true unless StatusPage.config.basic_auth_credentials

      credentials = StatusPage.config.basic_auth_credentials
      authenticate_or_request_with_http_basic do |name, password|
        name == credentials[:username] && password == credentials[:password]
      end
    end
  end
end
