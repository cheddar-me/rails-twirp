require "twirp/encoding"

module RailsTwirp
  class IntegrationTest < ActiveSupport::TestCase
    Response = Struct.new(:status, :body, :headers)

    attr_reader :response, :request, :controller
    attr_writer :mount_path

    def initialize(name)
      super
      reset!
      @before_rpc = []
      @mount_path = "/twirp"
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

      env = build_rack_env(service, rpc, request, headers)
      @before_rpc.each do |hook|
        hook.call(env)
      end

      status, headers, body = app.call(env)
      @response = decode_rack_response(service, rpc, status, headers, body)
      set_controller_from_rack_env(env)

      @response
    end

    def app
      RailsTwirp.test_app
    end

    private

    def build_rack_env(service, rpc, request, headers)
      env = {
        "CONTENT_TYPE" => request_content_type,
        "HTTP_HOST" => "localhost",
        "PATH_INFO" => "#{@mount_path}/#{service.service_full_name}/#{rpc}",
        "REQUEST_METHOD" => "POST"
      }
      if headers.present?
        http_request = ActionDispatch::Request.new(env)
        http_request.headers.merge! headers
      end

      input_class = service.rpcs[rpc][:input_class]
      env["rack.input"] = StringIO.new(Twirp::Encoding.encode(request, input_class, request_content_type))
      env
    end

    def request_content_type
      Twirp::Encoding::PROTO
    end

    def decode_rack_response(service, rpc, status, headers, body)
      body = body.join # body is an Enumerable

      if status === 200
        output_class = service.rpcs[rpc][:output_class]
        Twirp::Encoding.decode(body, output_class, headers["Content-Type"])
      else
        Twirp::Client.error_from_response(Response.new(status, body, headers))
      end
    end

    def set_controller_from_rack_env(env)
      @controller = ActionDispatch::Request.new(env).controller_class
    end
  end
end
