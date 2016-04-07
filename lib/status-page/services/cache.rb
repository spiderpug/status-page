module StatusPage
  module Services
    class CacheException < StandardError; end

    class Cache < Base
      def check!
        time = Time.now.to_s

        Rails.cache.write(key, time)
        fetched = Rails.cache.read(key)

        raise "different values (now: #{time}, fetched: #{fetched})" if fetched != time
      rescue Exception => e
        raise CacheException.new(e.message)
      end

      private

      def key
        @key ||= ['status-cache', request.try(:remote_ip)].join(':')
      end
    end
  end
end
