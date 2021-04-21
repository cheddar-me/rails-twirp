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

    def rpc(svc, rpc, request, headers: nil)
      @request = request
      input_class = svc.rpcs[rpc][:input_class]
      output_class = svc.rpcs[rpc][:output_class]

      content_type = Twirp::Encoding::PROTO
      env = {
        "CONTENT_TYPE" => content_type,
        "HTTP_HOST" => "localhost",
        "PATH_INFO" => "#{@mount_path}/#{svc.service_full_name}/#{rpc}",
        "REQUEST_METHOD" => "POST"
      }
      http_request = ActionDispatch::Request.new(env)
      http_request.headers.merge! headers if headers.present?

      env["rack.input"] = StringIO.new(Twirp::Encoding.encode(request, input_class, content_type))

      @before_rpc.each do |hook|
        hook.call(env)
      end

      status, headers, body = app.call(env)
      body = body.join
      response = if status === 200
        Twirp::Encoding.decode(body, output_class, headers["Content-Type"])
      else
        Twirp::Client.error_from_response(Response.new(status, body, headers))
      end

      @response = response
      @controller = http_request.controller_instance
      response
    end

    def app
      RailsTwirp.test_app
    end
  end
end
