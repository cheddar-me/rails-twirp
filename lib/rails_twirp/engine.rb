# frozen_string_literal: true

require "rails_twirp/application"
require "rails_twirp/route_set"
require "rails/railtie"

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
      # This hook is called when RailsTwirp::Base is initialized, and it sets the logger
      ActiveSupport.on_load(:rails_twirp) { self.logger ||= Rails.logger }
    end

    initializer :add_paths, before: :bootstrap_hook do |app|
      app.config.paths.add "config/twirp/routes.rb"
      app.config.paths.add "config/twirp/routes", glob: "**/*.rb"
      app.config.paths.add "proto", load_path: true
    end

    initializer :set_controller_view_path do |app|
      views = app.config.paths["app/views"].existent
      unless views.empty?
        ActiveSupport.on_load(:rails_twirp) { prepend_view_path views }
      end
    end

    initializer "rails_twirp.helpers" do |app|
      ActiveSupport.on_load(:rails_twirp) do
        # Load all the application helpers into the controller.
        # Note that helpers need to be set up here, because apparently
        # the AbstractController::Helpers module won't be able to find
        # the _helpers method on a reloaded controller
        include ActionController::Caching
        include app.routes.mounted_helpers
        extend ::AbstractController::Railties::RoutesHelpers.with(app.routes, false)
        extend ::ActionController::Railties::Helpers
        define_singleton_method(:inherited) do |klass|
          super(klass)

          # Have to call this explicitely, because ::ActionController::Railties::Helpers
          # checks if ActionController::Base is a parent class, which it isn't.
          # If we don't call this, the helpers don't get loaded
          klass.helper :all
        end
      end
    end

    initializer :add_twirp do |app|
      # Here we add the 'twirp' method to application, which is accessible at Rails.application.twirp
      app.extend TwirpValue
    end

    initializer :load_twirp_routes do |app|
      # Load route files
      [
        *app.config.paths["config/twirp/routes.rb"].existent,
        *app.config.paths["config/twirp/routes"].existent
      ].each do |path|
        load path
      end

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
