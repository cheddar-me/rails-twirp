module RailsTwirp
  class IntegrationTest < ActiveSupport::TestCase
    attr_reader :response, :request, :controller

    def initialize(name)
      super
      reset!
      @before_rpc = []
    end

    def reset!
      @request = nil
      @response = nil
    end

    def before_rpc(&block)
      @before_rpc << block
    end

    def rpc(service, rpc, request, headers: nil)
      @request = request
      service = app.twirp.routes.services[service].to_service

      rack_env = {}
      http_request = ActionDispatch::Request.new(rack_env)
      http_request.headers.merge! headers if headers.present?
      env = {rack_env: rack_env}

      @before_rpc.each do |hook|
        hook.call(env)
      end

      response = service.call_rpc rpc, request, env
      @response = response
      @controller = http_request.controller_instance
      response
    end

    def app
      RailsTwirp.test_app
    end
  end
end
