require "abstract_controller/base"
require "abstract_controller/rendering"
require "action_view/rendering"
require "rails_twirp/render_pb"
require "rails_twirp/errors"
require "abstract_controller/asset_paths"
require "abstract_controller/caching"
require "abstract_controller/logger"
require "abstract_controller/callbacks"
require "rails_twirp/rescue"

module RailsTwirp
  class Base < AbstractController::Base
    abstract!

    # The order of these includes matter.
    # The rendering modules extend each other, so need to be in this order.
    include AbstractController::Rendering
    include ActionView::Rendering
    include RenderPb
    include Errors

    # These add helpers for the controller
    include AbstractController::AssetPaths
    include AbstractController::Caching
    include AbstractController::Logger

    # These need to be last so errors can be handled as early as possible.
    include AbstractController::Callbacks
    include Rescue

    attr_internal :request, :env, :response_class
    def initialize
      @_request = nil
      @_env = nil
      @_response_class = nil
      super
    end

    def http_request
      @_http_request ||= ActionDispatch::Request.new(env[:rack_env])
    end

    def dispatch(action, request, response_class, env = {})
      self.request = request
      self.env = env
      self.response_class = response_class

      http_request.controller_instance = self

      process(action)

      # Implicit render
      self.response_body = render unless response_body
      response_body
    end

    def self.dispatch(action, request, response_class, env = {})
      new.dispatch(action, request, response_class, env)
    end

    # Used by the template renderer to figure out which template to use
    def details_for_lookup
      {formats: [:pb], handlers: [:pbbuilder]}
    end

    ActiveSupport.run_load_hooks(:rails_twirp, self)
  end
end
