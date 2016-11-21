module StatusPage
  module Services
    class DatabaseException < StandardError; end

    class Database < Base
      prepend Metrics::ServiceAdapter

      def check!
        # Check connection to the DB:
        ActiveRecord::Migrator.current_version

        time = Benchmark.ms do
          ActiveRecord::Base.descendants.each do |klass|
            klass.first unless klass.abstract_class?
          end
        end

        record_metric_value('query time', time, 'ms')
        nil
      rescue Exception => e
        raise DatabaseException.new(e.message)
      end
    end
  end
end
