# frozen_string_literal: true

require "twirp/error"

module RailsTwirp
  module ExceptionHandling
    extend ActiveSupport::Concern

    include AbstractController::Logger

    def process_action(*)
      super
    rescue => e
      # Only the exceptions which are not captured by ActionController-like "rescue_from" end up here.
      # The idea is that any exception which is rescued by the controller is treated as part of the business
      # logic, and thus taking action on it is the responsibility of the controller which uses "rescue_from".
      # If an exception ends up here it means it wasn't captured by the handlers defined in the controller.

      # We adopt the same error handling logic as Rails' standard middlewares:
      # 1. When we 'show exceptions' we make the exception bubble up—this is useful for testing
      #    If the exception gets raised here error reporting will happen in the middleware of the APM package
      #    higher in the call stack.
      #

      # A backtrace cleaner acts like a filter that only shows us the backtrace
      # with usefull lines compared to all lines the code goes through.
      backtrace_cleaner = http_request.get_header("action_dispatch.backtrace_cleaner")

      # Contians various exception related methods we can use and takes the backtrace_cleaner into consideration
      exception_wrapper = ActionDispatch::ExceptionWrapper.new(backtrace_cleaner, e)
      # ExceptionWrapper.show? contains the logic that chooses to pass exceptions through or not based on the
      # `action_dispatch.show_exceptions` config settings of :none, :rescuable and :all
      raise e unless exception_wrapper.show?(http_request)

      # 2. We report the error to the error tracking service, this needs to be configured.
      RailsTwirp.unhandled_exception_handler&.call(e)

      # 3. When we want to show detailed exceptions we include the exception message in the error
      if http_request.get_header("action_dispatch.show_detailed_exceptions")
        self.response_body = Twirp::Error.internal_with(e)
        return
      end

      # 4. Otherwise we just return a vague internal error message
      self.response_body = Twirp::Error.internal("Internal error")
    end
  end
end
