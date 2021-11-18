require "test_helper"

class DummyControllerTest < RailsTwirp::IntegrationTest
  test "controller gets rpc name" do
    req = RPC::DummyAPI::RpcNameCheckRequest.new()
    rpc RPC::DummyAPI::DummyService, "RpcNameCheck", req
    assert_instance_of RPC::DummyAPI::RpcNameCheckResponse, response
    assert_equal "RpcNameCheck", response.rpc_name
  end
end
