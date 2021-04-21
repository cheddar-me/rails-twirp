require "active_support/log_subscriber"

module RailsTwirp
  class LogSubscriber < ActiveSupport::LogSubscriber
    def start_processing(event)
      return unless logger.info?

      payload = event.payload

      info "Processing by #{payload[:controller]}##{payload[:action]}"
    end

    def process_action(event)
      payload = event.payload
      exception_raised(payload[:http_request], payload[:exception_object]) if payload[:exception_object]

      info do
        code = payload.fetch(:code, :internal)

        message = +"Completed #{code} in #{event.duration.round}ms (Allocations: #{event.allocations})"
        message << "\n\n" if defined?(Rails.env) && Rails.env.development?

        message
      end
    end

    private

    def exception_raised(request, exception)
      backtrace_cleaner = request.get_header("action_dispatch.backtrace_cleaner")
      wrapper = ActionDispatch::ExceptionWrapper.new(backtrace_cleaner, exception)

      log_error(wrapper)
    end

    def log_error(wrapper)
      exception = wrapper.exception
      trace = wrapper.exception_trace

      message = []
      message << "  "
      message << "#{exception.class} (#{exception.message}):"
      message.concat(exception.annotated_source_code) if exception.respond_to?(:annotated_source_code)
      message << "  "
      message.concat(trace)

      log_array(message)
    end

    def log_array(array)
      lines = Array(array)

      return if lines.empty?

      if logger.formatter&.respond_to?(:tags_text)
        fatal { lines.join("\n#{logger.formatter.tags_text}") }
      else
        fatal { lines.join("\n") }
      end
    end
  end
end

RailsTwirp::LogSubscriber.attach_to :rails_twirp
