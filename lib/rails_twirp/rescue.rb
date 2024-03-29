# frozen_string_literal: true

module RailsTwirp
  module Rescue
    extend ActiveSupport::Concern
    include ActiveSupport::Rescuable

    private

    def process_action(*)
      super
    rescue => e
      rescue_with_handler(e) || raise
    end
  end
end
