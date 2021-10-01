require_relative "../../proto/api_twirp"

Rails.application.twirp.routes.draw do
  service RPC::DummyAPI::DummyService do
    rpc "Ping", to: "pings#ping"
    rpc "PingRender", to: "pings#ping_render"
    rpc "PingTemplate", to: "pings#ping_template"
    rpc "ErrorResponse", to: "pings#error_response"
    rpc "RaiseError", to: "pings#raise_error"
    rpc "UncaughtError", to: "pings#uncaught_raise"
    rpc "BeforeError", to: "pings#before_error"
  end

  scope module: :testmod do
    service RPC::DummyAPI::DummyService do
      scope module: "nested" do
        rpc "Nested", to: "other#ping"
      end
    end
  end
end
