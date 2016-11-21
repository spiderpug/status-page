# status-page

[![Build Status](https://travis-ci.org/spiderpug/status-page.svg)](https://travis-ci.org/spiderpug/status-page)

Mountable status page for your Rails application, to check (DB, Cache, Sidekiq, Redis, etc.).

Mounting this gem will add a '/status' route to your application, which can be used for health monitoring the application and its various services. The method will return an appropriate HTTP status as well as a JSON array representing the state of each service.

## Example

<img src="https://cloud.githubusercontent.com/assets/2295856/20490906/e7c2a3d2-b00f-11e6-818f-ea2a4d3cd81f.png" />

## Install

```ruby
# Gemfile
gem 'status-page'
```

Then run:

```bash
$ bundle install
```

```ruby
# config/routes.rb
mount StatusPage::Engine, at: '/'
```

## Supported service services

The following services are currently supported:

* DB
* Cache
* Redis
* Sidekiq
* Resque

## Configuration

### Adding services

By default, only the database check is enabled. You can add more service services by explicitly enabling them via an initializer:

```ruby
StatusPage.configure do
  # Cache check status result 10 seconds
  self.interval = 10
  # Use service
  self.use :database
  self.use :cache
  self.use :redis
  # Custom redis url
  self.use :redis, url: 'redis://you-redis-host:3306/1'
  # Custom service title
  self.use :redis, title: 'Redis (other.host.com)', url: 'redis://you-other-host:3306/1'
  self.use :sidekiq
  self.use :elasticsearch, options: { hosts: ... }, test_index: 'myindex', test_query: { query: ... }
  self.use :delayedjob, pid_files: ['path/to/pid.1.pid'] # pid_files is optional.
end
```

### Adding a custom service

It's also possible to add custom health check services suited for your needs (of course, it's highly appreciated and encouraged if you'd contribute useful services to the project).

In order to add a custom service, you'd need to:

* Implement the `StatusPage::Services::Base` class and its `check!` method (a check is considered as failed if it raises an exception):

```ruby
class CustomService < StatusPage::Services::Base
  def check!
    raise 'Oh oh!'
  end
end
```
* Add its class to the config:

```ruby
StatusPage.configure do
  self.add_custom_service(CustomService)
end
```

You can also pass some options to your custom service, you'd need to:

* Implement the `StatusPage::Services::Base` class, `check!` method (a check is considered as failed if it raises an exception), and its Configuration class:

```ruby
class CustomService < StatusPage::Services::Base
  class Configuration
    DEFAULT_HOST = "127.0.0.1"

    attr_accessor :host

    def initialize
      @host = DEFAULT_HOST
    end
  end

  def check!
    raise 'Oh oh!'
  end

  private

  class << self
    def config_class
      CustomService::Configuration
    end
  end
end
```
* Add its class to the config, and options as well:

```ruby
StatusPage.configure do
  self.add_custom_service(CustomService, host: '192.168.1.2')
end
```

### Metric recording

In case you want fancy graphs of various metrics you have to enable metric recording:

```ruby
StatusPage.configure do
  self.record_metrics = true
  # custom classes are possible. MemoryRecorder is the default
  self.recorder_class = StatusPage::Metrics::MemoryRecorder
end
```

You can use the provided ActiveRecord adapter to store metrics data in a database:

```ruby
# in your application, prepare an ActiveRecord model:
class MyMetric < ApplicationRecord
  # t.string :my_scope_col
  # t.float :f_value
  # t.timestamps
end

# attach a recorder class to your model:
class MyMetricRecorder < StatusPage::Metrics::ActiveRecordRecorder
  def model; MyMetric; end
  def scope_column; :my_scope_col; end
  def value_column; :f_value; end
  def timestamp_column; :created_at; end
end

StatusPage.configure do
  self.record_metrics = true
  self.recorder_class = MyMetricRecorder
end
```

### Adding a custom error callback

If you need to perform any additional error handling (for example, for additional error reporting), you can configure a custom error callback:

```ruby
StatusPage.configure do
  self.error_callback = proc do |e|
    logger.error "Health check failed with: #{e.message}"

    Raven.capture_exception(e)
  end
end
```

### Adding authentication credentials

By default, the `/status` endpoint is not authenticated and is available to any user. You can authenticate using HTTP Basic Auth by providing authentication credentials:

```ruby
StatusPage.configure do
  self.basic_auth_credentials = {
    username: 'SECRET_NAME',
    password: 'Shhhhh!!!'
  }
end
```

## License

The MIT License (MIT)
