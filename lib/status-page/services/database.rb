module StatusPage
  module Services
    class DatabaseException < StandardError; end

    class Database < Base
      def check!
        # Check connection to the DB:
        ActiveRecord::Migrator.current_version
        nil
      rescue Exception => e
        raise DatabaseException.new(e.message)
      end
    end
  end
end
