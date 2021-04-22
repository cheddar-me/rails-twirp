module RailsTwirp
  module Instrumentation
    extend ActiveSupport::Concern

    include AbstractController::Logger

    def process_action(*)
      raw_payload = {
        controller: self.class.name,
        action: action_name,
        request: request,
        http_request: http_request,
        headers: http_request.headers,
        path: http_request.fullpath
      }

      ActiveSupport::Notifications.instrument("start_processing.rails_twirp", raw_payload)

      ActiveSupport::Notifications.instrument("process_action.rails_twirp", raw_payload) do |payload|
        result = super
        if response_body.is_a?(Twirp::Error)
          payload[:code] = response_body.code
          payload[:msg] = response_body.msg
        else
          payload[:code] = :success
        end
        payload[:response] = response_body
        result
      end
    end
  end
end
