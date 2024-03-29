# frozen_string_literal: true

# Most of this logic is stolen from Rails ActionDispatch::Routing::RouteSet

require "rails_twirp/mapper"

module RailsTwirp
  class UnknownRpcError < StandardError; end

  class RouteSet
    attr_reader :services

    def initialize
      # Make services a hash with a default_proc, so the same class gets reused if the service
      # method is used multiple times with the same key.
      # This makes it possible to split up the routes into multiple files.
      @services = Hash.new { |hash, key| hash[key] = ServiceRouteSet.new(key) }
    end

    def draw(&block)
      mapper = Mapper.new(self)
      mapper.instance_exec(&block)
    end

    def to_services
      services.each_value.map(&:to_service)
    end

    class ServiceRouteSet
      attr_reader :rpcs

      def initialize(service_class)
        @service_class = service_class
        @service_class.raise_exceptions = true

        @rpcs = {}
      end

      def add_route(name, mapping)
        if @rpcs[name]
          raise ArgumentError, "Invalid RPC, route already defined: #{name}"
        end

        @rpcs[name] = mapping
      end

      def to_service
        # Synthesize a handler that will process the requests
        #
        handler = Class.new
        @rpcs.each do |name, mapping|
          rpc_info = @service_class.rpcs[name]
          raise UnknownRpcError, "Unknown RPC #{name} on #{@service_class.service_name} service" unless rpc_info
          method_name = rpc_info[:ruby_method]

          # Stolen from Rails in ActionDispatch::Request#controller_class_for
          action_name = mapping.action
          response_class = rpc_info[:output_class]

          handler.define_method(method_name) do |req, env|
            controller_name = mapping.controller.underscore
            const_name = controller_name.camelize << "Controller"
            controller_class = const_name.constantize
            controller_class.dispatch(action_name, req, response_class, name, env)
          end
        end

        service = @service_class.new(handler.new)
        service.before do |rack_env, env|
          env[:rack_env] = rack_env
        end
        service
      end
    end
  end
end
