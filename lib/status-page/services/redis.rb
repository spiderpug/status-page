require 'redis/namespace'

module StatusPage
  module Services
    class RedisException < StandardError; end

    class Redis < Base
      def check!
        time = Time.now.to_s(:db)

        redis = ::Redis.current
        redis.set(key, time)
        fetched = redis.get(key)

        raise "different values (now: #{time}, fetched: #{fetched})" if fetched != time
      rescue Exception => e
        raise RedisException.new(e.message)
      ensure
        redis.client.disconnect
      end

      private

      def key
        @key ||= ['status-redis', request.try(:remote_ip)].join(':')
      end
    end
  end
end
