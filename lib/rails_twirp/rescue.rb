# frozen_string_literal: true

module RailsTwirp
  module Rescue
    extend ActiveSupport::Concern
    include ActiveSupport::Rescuable

    private

    def process_action(*)
      super
    rescue Exception => exception
      rescue_with_handler(exception) || raise
    end
  end
end
