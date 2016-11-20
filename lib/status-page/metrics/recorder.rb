module StatusPage
  module Metrics
    class Recorder
      attr_reader :data, :keep, :unit

      def initialize(keep: 5.minutes, unit: 'ms')
        @data = {}
        @keep = keep
        @unit = unit
      end

      def update(value, override: true)
        time = Time.now.to_i

        if override || !@data.key?(time)
          @data[time] = value
        end

        prune
        @data[time]
      end

      private

      def prune
        timestamps = data.keys
        since = (Time.now - keep).to_i

        timestamps.each{|t| data.delete(t) if t < since}
      end
    end
  end
end
