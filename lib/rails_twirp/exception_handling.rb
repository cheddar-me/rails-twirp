require "twirp/error"

module RailsTwirp
  module ExceptionHandling
    extend ActiveSupport::Concern

    include AbstractController::Logger

    def process_action(*)
      super
    rescue Exception => e
      # We adopt the same error handling logic as Rails' standard middlewares:
      # 1. When we 'show exceptions' we make the exception bubble up—this is useful for testing
      raise e unless http_request.show_exceptions?

      # 2. When we want to show detailed exceptions we include the exception message in the error
      if http_request.get_header("action_dispatch.show_detailed_exceptions")
        self.response_body = Twirp::Error.internal_with(e)
      else
        # 3. Otherwise we just return a vague internal error message
        self.response_body = Twirp::Error.internal("Internal error")
      end
    end
  end
end
