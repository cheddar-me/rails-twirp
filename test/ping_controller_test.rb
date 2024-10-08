# frozen_string_literal: true

require "test_helper"

class PingControllerTest < RailsTwirp::IntegrationTest
  test "you can ping it" do
    req = RPC::DummyAPI::PingRequest.new(name: "Bouke")
    rpc RPC::DummyAPI::DummyService, "Ping", req
    assert_equal "BoukeBouke", response.double_name
  end

  test "you can ping render" do
    req = RPC::DummyAPI::PingRequest.new(name: "Bouke")
    rpc RPC::DummyAPI::DummyService, "PingRender", req
    refute_instance_of Twirp::Error, response
    assert_equal "http://www.example.com/twirp BoukeBouke", response.double_name
  end

  test "you can ping render with host and https" do
    host! "localhost"
    https!
    req = RPC::DummyAPI::PingRequest.new(name: "Bouke")
    rpc RPC::DummyAPI::DummyService, "PingRender", req
    refute_instance_of Twirp::Error, response
    assert_equal "https://localhost/twirp BoukeBouke", response.double_name
  end

  test "you can ping template" do
    req = RPC::DummyAPI::PingRequest.new(name: "Bouke")
    rpc RPC::DummyAPI::DummyService, "PingTemplate", req
    refute_instance_of Twirp::Error, response
    assert_equal "BoukeBouke", response.double_name
  end

  test "error response" do
    req = RPC::DummyAPI::PingRequest.new
    rpc RPC::DummyAPI::DummyService, "ErrorResponse", req
    assert_instance_of Twirp::Error, response
    assert_equal "You are not authenticated!!", response.msg
    assert_equal :unauthenticated, response.code
  end

  test "raise error" do
    req = RPC::DummyAPI::PingRequest.new
    rpc RPC::DummyAPI::DummyService, "RaiseError", req
    assert_instance_of Twirp::Error, response
    assert_equal "Not found", response.msg
    assert_equal :not_found, response.code
  end

  test "uncaught errors should bubble up to the test" do
    Rails.application.env_config["action_dispatch.show_exceptions"] = :none

    req = RPC::DummyAPI::PingRequest.new
    assert_raises StandardError, "Uncaught" do
      rpc RPC::DummyAPI::DummyService, "UncaughtError", req
    end
  end

  test "uncaught errors should return an internal error with details if show_exceptions is all" do
    Rails.application.env_config["action_dispatch.show_exceptions"] = :all

    req = RPC::DummyAPI::PingRequest.new
    rpc RPC::DummyAPI::DummyService, "UncaughtError", req
    assert_instance_of Twirp::Error, response
    assert_equal :internal, response.code
    assert_equal "Uncaught", response.msg
    assert_equal "StandardError", response.meta["cause"]
  end

  test "uncaught errors should be fanned out to the exception handler proc if one is defined" do
    Rails.application.env_config["action_dispatch.show_exceptions"] = :all

    captured_exception = nil
    RailsTwirp.unhandled_exception_handler = ->(e) { captured_exception = e }

    req = RPC::DummyAPI::PingRequest.new
    rpc RPC::DummyAPI::DummyService, "UncaughtError", req
    assert_instance_of Twirp::Error, response
    assert_equal :internal, response.code
    assert_equal "Uncaught", response.msg
    assert_equal "StandardError", response.meta["cause"]
    assert_kind_of StandardError, captured_exception
  ensure
    RailsTwirp.unhandled_exception_handler = nil
  end

  test "uncaught errors should return an internal error without if show_exceptions is true and show_detailed_exceptions is false" do
    Rails.application.env_config["action_dispatch.show_exceptions"] = :all
    Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false

    req = RPC::DummyAPI::PingRequest.new
    rpc RPC::DummyAPI::DummyService, "UncaughtError", req
    assert_instance_of Twirp::Error, response
    assert_equal :internal, response.code
    assert_equal "Internal error", response.msg
  ensure
    Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = true
  end

  test "before error" do
    req = RPC::DummyAPI::PingRequest.new
    rpc RPC::DummyAPI::DummyService, "BeforeError", req
    assert_instance_of Twirp::Error, response
    assert_equal "yOuR ReQuEsT Is mAlFoRmEd", response.msg
    assert_equal :malformed, response.code
  end

  test "controller is set to the controller that handled the request" do
    req = RPC::DummyAPI::PingRequest.new(name: "Bouke")
    rpc RPC::DummyAPI::DummyService, "Ping", req
    assert_instance_of PingsController, controller
  end
end
