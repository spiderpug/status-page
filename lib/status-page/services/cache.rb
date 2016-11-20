module StatusPage
  module Services
    class CacheException < StandardError; end

    class Cache < Base
      prepend Metrics::ServiceAdapter

      def check!
        time = Time.now.to_s

        ms = Benchmark.ms do
          Rails.cache.write(key, time)
          fetched = Rails.cache.read(key)
          raise "different values (now: #{time}, fetched: #{fetched})" if fetched != time
        end

        record_metric_value("Write+Read", ms, "ms")
        nil
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
