module StatusPage
  module Metrics
    class TimeSeries
      def initialize(names: [], keep: 15.minutes)
        @recorders = {}
        @keep = keep
        names.each{|name| @recorders[name] = Recorder.new(keep: keep)}
      end

      def record_value(name, value, unit)
        if @recorders[name].nil?
          @recorders[name] = Recorder.new(keep: @keep, unit: unit)
        end

        @recorders[name].update(value)
      end

      def record_error
        @recorders.each{|(name, r)| r.update(0, override: false)}
        true
      end

      def data
        @recorders.inject([]) do |ary, (name, recorder)|
          ary << {
            name: name,
            data: recorder.data.map{|k, v| [k.to_i, v]},
            unit: recorder.unit,
          }
          ary
        end
      end
    end
  end
end
