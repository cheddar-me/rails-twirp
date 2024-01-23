# frozen_string_literal: true

require "twirp/error"

module RailsTwirp
  module ExceptionHandling
    extend ActiveSupport::Concern

    include AbstractController::Logger

    def process_action(*)
      super
    rescue Exception => e
      # Only the exceptions which are not captured by ActionController-like "rescue_from" end up here.
      # The idea is that any exception which is rescued by the controller is treated as part of the business
      # logic, and thus taking action on it is the responsibility of the controller which uses "rescue_from".
      # If an exception ends up here it means it wasn't captured by the handlers defined in the controller.

      # We adopt the same error handling logic as Rails' standard middlewares:
      # 1. When we 'show exceptions' we make the exception bubble up—this is useful for testing
      #    If the exception gets raised here error reporting will happen in the middleware of the APM package
      #    higher in the call stack.
      #
      # Note that between Rails 7.0 and 7.1 the show_exceptions? helper method on Request
      # got removed, so we must make do with the config access instead.
      raise e unless [true, :all].include?(http_request.get_header("action_dispatch.show_exceptions"))

      # 2. We report the error to the error tracking service, this needs to be configured.
      RailsTwirp.unhandled_exception_handler&.call(e)

      # 2b. If the error is very severe (not a StandardError but something like ENOMEM,
      # process termination, kill signal...) just re-raise it. These exceptions should never
      # be swallowed.
      raise e unless e.is_a?(StandardError)

      # 3. When we want to show detailed exceptions we include the exception message in the error
      if http_request.get_header("action_dispatch.show_detailed_exceptions")
        self.response_body = Twirp::Error.internal_with(e)
      else
        # 4. Otherwise we just return a vague internal error message
        self.response_body = Twirp::Error.internal("Internal error")
      end

      decorate_twirp_error_response! if respond_to?(:decorate_twirp_error_response!)

      self.response_body
    end
  end
end
