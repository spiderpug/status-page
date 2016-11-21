module StatusPage
  module Metrics
    class ActiveRecordRecorder < BaseRecorder
      attr_reader :model, :scope_column, :value_column, :timestamp_column

      def initialize(*args)
        super
        @written_updates = 0
      end

      def data
        data_array = model.\
          where(model.arel_table[timestamp_column].gteq(Time.now - keep)).\
          where(scope_column => @scope).\
          pluck(timestamp_column, value_column)

        Hash[data_array]
      end

      def update(value, override: true)
        @written_updates += 1

        timestamp = Time.now

        if override
          model.find_or_initialize_by({
            scope_column => @scope,
            timestamp_column => timestamp,
          }).update_attributes!(value_column => value)
        else
          model.first_or_create!({
            scope_column => @scope,
            timestamp_column => timestamp,
            value_column => value,
          })
        end

        if @written_updates > 1
          prune
          @written_updates = 0
        end

        value
      end

      private

      def prune
        model.where(model.arel_table[timestamp_column].lteq(Time.now - keep)).destroy_all
      end
    end
  end
end
