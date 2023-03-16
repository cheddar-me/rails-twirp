# frozen_string_literal: true

module RailsTwirp
  # RenderPb makes it possible to do 'render pb: <proto object>', skipping templates
  # The way this module is written is inspired by ActionController::Renderers
  module RenderPb
    def render_to_body(options)
      _render_to_body_with_pb(options) || super
    end

    def _render_to_body_with_pb(options)
      if options.include? :pb
        _process_options(options)
        return options[:pb]
      end

      nil
    end
  end
end
