class PingsController < ApplicationTwirpController
  before_action :respond_error, only: :before_error

  def ping
    response = RPC::DummyAPI::PingResponse.new(double_name: request.name * 2)
    self.response_body = response
  end

  def ping_render
    response = RPC::DummyAPI::PingResponse.new(double_name: request.name * 2)
    render pb: response
  end

  def ping_template
    @double_name = request.name * 2
  end

  def error_response
    error :unauthenticated, "You are not authenticated!!"
  end

  def raise_error
    # This error is rescued in ApplicationTwirpController
    raise ActiveRecord::RecordNotFound, "Not found"
  end

  def before_error
    # This error won't be reached because of the before_action
    raise NotImplementedError
  end

  def respond_error
    error :malformed, "yOuR ReQuEsT Is mAlFoRmEd"
  end
end
