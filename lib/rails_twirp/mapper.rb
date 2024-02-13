# frozen_string_literal: true

require "forwardable"

module RailsTwirp
  class ServiceMapper
    class Mapping
      attr_reader :controller, :action

      def initialize(to:, **options)
        controller, @action = split_to(to)
        @controller = add_controller_module(controller, options.delete(:module))
        raise ArgumentError, "Unknown argument #{options.keys.first}" unless options.empty?
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

      def add_controller_module(controller, modyoule)
        return controller unless modyoule

        if controller&.start_with?("/")
          -controller[1..]
        else
          -[modyoule, controller].compact.join("/")
        end
      end
    end

    extend Forwardable
    def_delegator :@mapper, :scope

    def initialize(service_route_set, mapper)
      @service_route_set = service_route_set
      @mapper = mapper
    end

    def rpc(name, to:)
      mapping = Mapping.new(to: to, module: @mapper.send(:_module))
      @service_route_set.add_route(name, mapping)
    end
  end

  class Mapper
    def initialize(route_set)
      @route_set = route_set
      @module = nil
    end

    def service(service_definition, **, &block)
      service_route_set = @route_set.services[service_definition]
      service_mapper = ServiceMapper.new(service_route_set, self)
      scope(**) { service_mapper.instance_exec(&block) }
    end

    def scope(**options)
      last_module = @module
      if (modyoule = options.delete(:module))
        @module = @module.nil? ? modyoule : "#{@module}/#{modyoule}"
      end
      raise ArgumentError, "Unknown scope argument #{options.keys.first}" unless options.empty?
      yield
    ensure
      @module = last_module
    end

    private

    def _module
      @module
    end
  end
end
