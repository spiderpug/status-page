require 'status-page/providers/base'
require 'resque'

module StatusPage
  module Providers
    class ResqueException < StandardError; end

    class Resque < Base
      def check!
        ::Resque.info
      rescue Exception => e
        raise ResqueException.new(e.message)
      end
    end
  end
end
