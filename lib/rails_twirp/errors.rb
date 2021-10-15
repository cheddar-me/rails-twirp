require "twirp/error"

module RailsTwirp
  module Errors
    # Helper that sets the response to a Twirp Error
    # The valid error codes can be found in Twirp::ERROR_CODES
    def error(code, message, meta: nil, exception: nil)
      if exception.present?
        Rails.logger.error(exception.message)
        Rails.logger.error(exception.backtrace.join("\n"))
      end

      Rails.logger.error("code=#{code} message=#{message} meta=[#{stringify_meta(meta)}]")
      self.response_body = Twirp::Error.new(code, message, meta)
    end

    private

    def stringify_meta(meta)
      return "" if meta.nil?

      meta.to_a.each do |kv_pair|
        kv_pair.join("=")
      end.join(" ")
    end
  end
end
