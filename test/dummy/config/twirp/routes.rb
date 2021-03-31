require "api_twirp"

Rails.application.twirp.routes.draw do
  service RPC::DummyAPI::DummyService do
    rpc "Ping", to: "pings#ping"
  end
end
