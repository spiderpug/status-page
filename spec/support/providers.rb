require 'spec_helper'

module Services
  include RSpec::Mocks::ExampleMethods

  extend self

  def stub_cache_failure
    allow(Rails.cache).to receive(:read).and_return(false)
  end

  def stub_database_failure
    allow(ActiveRecord::Migrator).to receive(:current_version).and_raise(Exception)
  end

  def stub_elasticsearch_failure
    allow_any_instance_of(::Elasticsearch::Transport::Client).to receive(:cluster).and_raise(Exception)
  end

  def stub_redis_failure
    allow_any_instance_of(Redis).to receive(:get).and_return(false)
  end

  def stub_resque_failure
    allow(Resque).to receive(:info).and_raise(Exception)
  end

  def stub_sidekiq_progresses_online
    allow_any_instance_of(Sidekiq::Stats).to receive(:processes_size).and_return(true)
  end

  def stub_sidekiq_latency_failure
    allow_any_instance_of(Sidekiq::Queue).to receive(:latency).and_return(Float::INFINITY)
  end

  def stub_sidekiq_redis_failure
    allow(Sidekiq).to receive(:redis).and_raise(Redis::CannotConnectError)
  end
end
