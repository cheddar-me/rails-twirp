# Most of this logic is stolen from Rails ActionDispatch::Routing::RouteSet

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
          controller_name = mapping.controller.underscore
          const_name = controller_name.camelize << "Controller"
          action_name = mapping.action
          response_class = rpc_info[:output_class]

          handler.define_method(method_name) do |req, env|
            controller_class = ::ActiveSupport::Dependencies.constantize(const_name)
            controller_class.dispatch(action_name, req, response_class, env)
          end
        end

        service = @service_class.new(handler.new)
        service.before do |rack_env, env|
          env[:rack_env] = rack_env
        end
        service
      end
    end

    class Mapping
      attr_reader :controller, :action

      def initialize(to:)
        @controller, @action = split_to(to)
      end

      def to_s
        "#{controller}##{action}"
      end

      private

      # copied from Rails
      def split_to(to)
        if /#/.match?(to)
          to.split("#").map!(&:-@)
        else
          []
        end
      end
    end

    class ServiceMapper
      def initialize(service_route_set)
        @service_route_set = service_route_set
      end

      def rpc(name, to:)
        mapping = Mapping.new(to: to)
        @service_route_set.add_route(name, mapping)
      end
    end

    class Mapper
      def initialize(route_set)
        @route_set = route_set
      end

      def service(service_definition, &block)
        service_route_set = @route_set.services[service_definition]
        service_mapper = ServiceMapper.new(service_route_set)
        service_mapper.instance_exec(&block)
      end
    end
  end
end
