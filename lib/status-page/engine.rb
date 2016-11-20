module StatusPage
  class Engine < ::Rails::Engine
    isolate_namespace StatusPage

    initializer "status-page.assets.precompile" do |app|
      app.config.assets.precompile += %w(
        status_page/application.js
      )
    end
  end
end
