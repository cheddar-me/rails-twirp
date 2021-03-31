class PingsController < ApplicationTwirpController
  def ping
    response = RPC::DummyAPI::PingResponse.new(double_name: request.name * 2)
    self.response_body = response
  end
end
