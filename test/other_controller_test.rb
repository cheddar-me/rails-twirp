# frozen_string_literal: true

require "test_helper"

class OtherControllerTest < RailsTwirp::IntegrationTest
  test "modules work" do
    req = RPC::DummyAPI::PingRequest.new(name: "Bouke")
    rpc RPC::DummyAPI::DummyService, "Nested", req
    assert_equal "BoukeBouke", response.double_name
  end
end
