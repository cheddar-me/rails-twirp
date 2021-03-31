module RailsTwirp
  class Base < AbstractController::Base
    abstract!

    include AbstractController::Logger
    include AbstractController::AssetPaths
    include AbstractController::Callbacks
    include AbstractController::Caching
    include AbstractController::Rendering
    include ActionView::Rendering

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

    def render(*args)
      options = {formats: :pb, handlers: :pbbuilder, locals: {response_class: response_class}}
      options.deep_merge! args.extract_options!
      super(*args, options)
    end

    def self.dispatch(action, request, response_class, env = {})
      new.dispatch(action, request, response_class, env)
    end

    ActiveSupport.run_load_hooks(:rails_twirp, self)
  end
end
