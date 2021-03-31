require "test_helper"

class PingControllerTest < RailsTwirp::IntegrationTest
  test "you can ping it" do
    req = RPC::DummyAPI::PingRequest.new(name: "Bouke")
    rpc RPC::DummyAPI::DummyService, "Ping", req
    assert_equal "BoukeBouke", response.double_name
  end
end
