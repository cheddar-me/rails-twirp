# frozen_string_literal: true

class DummyController < RailsTwirp::Base
  def rpc_name_check
    @rpc_name = rpc_name
  end
end
