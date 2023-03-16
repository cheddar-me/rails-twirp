# frozen_string_literal: true

require "twirp/error"

module RailsTwirp
  module Errors
    # Helper that sets the response to a Twirp Error
    # The valid error codes can be found in Twirp::ERROR_CODES
    def error(code, message, meta = nil)
      self.response_body = Twirp::Error.new(code, message, meta)
    end
  end
end
