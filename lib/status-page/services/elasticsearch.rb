module StatusPage
  module Services
    class ElasticsearchException < StandardError; end

    class Elasticsearch < Base
      class Configuration
        attr_accessor :options, :test_index, :test_search

        def initialize
          @options = {}
          @test_index = '_all'
          @test_search = {query: {}, size: 0}
        end
      end

      class << self
        def config_class
          Elasticsearch::Configuration
        end
      end

      def check!
        es = ::Elasticsearch::Client.new(config.options)

        cluster_health = es.cluster.health

        if (color = cluster_health['status']) != 'green'
          raise ElasticsearchException.new("Cluster health is #{color}")
        end

        search_result = es.search(index: config.test_index, body: config.test_search)
        if search_result['timed_out']
          raise ElasticsearchException.new("Search timeout")
        end

        if (failed_shards = search_result['_shards']['failed']) > 0
          raise ElasticsearchException.new("Search failed on #{failed_shards} shards.")
        end
      rescue Exception => e
        raise ElasticsearchException.new(e.message)
      end
    end
  end
end
