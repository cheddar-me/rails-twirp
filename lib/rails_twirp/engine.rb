require "rails/railtie"
require "rails_twirp/application"

module RailsTwirp
  # Even though this is an engine, we don't inherit from Rails::Engine because we don't want anything it provides.
  class Engine < ::Rails::Railtie
    # Implement Rack API
    delegate :call, to: :routes

    module TwirpValue
      def twirp
        @twirp ||= Application.new
      end
    end

    initializer "rails_twirp.logger" do
      # This hook is called whenever a RailsTwirp::Base is initialized, and it sets the logger
      ActiveSupport.on_load(:rails_twirp) { self.logger ||= Rails.logger }
    end

    initializer :add_paths, before: :bootstrap_hook do |app|
      app.config.paths.add "config/twirp/routes.rb"
      app.config.paths.add "config/twirp/routes", glob: "**/*.rb"
      app.config.paths.add "app/twirp/controllers", eager_load: true
      app.config.paths.add "proto", load_path: true
      app.config.paths.add "app/twirp/views", load_path: true
    end

    initializer :set_controller_view_path do
      ActiveSupport.on_load(:rails_twirp) { prepend_view_path "app/twirp/views" }
    end

    initializer :add_twirp do |app|
      # Here we add the 'twirp' method to application, which is accessible at Rails.application.twirp
      app.extend TwirpValue
    end

    initializer :load_twirp_routes do |app|
      # Load route files
      route_configs = [
        *app.config.paths["config/twirp/routes.rb"].existent,
        *app.config.paths["config/twirp/routes"].existent
      ]
      load(*route_configs)

      # Create a router that knows how to route all the registered services
      services = app.twirp.routes.to_services
      routes.draw do
        services.each do |service|
          mount service => service.full_name
        end
      end
    end

    initializer :set_test_app do |app|
      RailsTwirp.test_app = app
    end

    def routes
      @routes ||= ActionDispatch::Routing::RouteSet.new
    end
  end
end
