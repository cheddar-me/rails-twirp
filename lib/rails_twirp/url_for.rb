require "abstract_controller/url_for"

module RailsTwirp
  module UrlFor
    extend ActiveSupport::Concern

    include AbstractController::UrlFor

    def url_options
      @_url_options ||= {
        host: http_request.host,
        port: http_request.optional_port,
        protocol: http_request.protocol
      }.merge!(super).freeze
    end
  end
end
