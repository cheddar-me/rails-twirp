# frozen_string_literal: true

class ApplicationTwirpController < RailsTwirp::Base
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def handle_not_found
    error :not_found, "Not found"
  end
end
