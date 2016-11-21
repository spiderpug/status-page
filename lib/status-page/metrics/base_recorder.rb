module StatusPage
  module Metrics
    class BaseRecorder
      attr_reader :data, :scope, :keep, :unit

      def initialize(scope:, keep: 5.minutes, unit: 'ms')
        @scope = scope
        @keep = keep
        @unit = unit
        @data = {}
      end

      def update(value, override: true)
      end
    end
  end
end
