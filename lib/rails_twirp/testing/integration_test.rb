# frozen_string_literal: true

require "twirp/encoding"

module RailsTwirp
  class IntegrationTest < ActiveSupport::TestCase
    DEFAULT_HOST = "www.example.com"
    Response = Struct.new(:status, :body, :headers)

    attr_reader :response, :request, :controller
    attr_writer :mount_path
    alias_method :mount_path!, :mount_path=

    def initialize(name)
      super
      reset!
      @before_rpc = []
    end

    def host
      @host || DEFAULT_HOST
    end
    attr_writer :host
    alias_method :host!, :host=

    def https?
      @https
    end

    def https!(value = true)
      @https = value
    end

    def reset!
      @request = nil
      @response = nil
      @host = nil
      @host = nil
      @https = false
      @mount_path = "/twirp"
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
        "HTTPS" => https? ? "on" : "off",
        "HTTP_HOST" => host,
        "PATH_INFO" => "#{@mount_path}/#{service.service_full_name}/#{rpc}",
        "REQUEST_METHOD" => "POST",
        "SERVER_NAME" => host,
        "SERVER_PORT" => https? ? "443" : "80",
        "rack.url_scheme" => https? ? "https" : "http"
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
      body_bytes = StringIO.new("".b)
      body.each { |b| body_bytes << b }

      if status === 200
        output_class = service.rpcs[rpc][:output_class]
        Twirp::Encoding.decode(body_bytes.string, output_class, headers["Content-Type"])
      else
        Twirp::Client.error_from_response(Response.new(status, body_bytes.string, headers))
      end
    ensure
      body.close if body.respond_to?(:close) # Comply with Rack API
    end

    def set_controller_from_rack_env(env)
      @controller = ActionDispatch::Request.new(env).controller_instance
    end
  end
end
