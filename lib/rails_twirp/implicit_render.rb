# frozen_string_literal: true

require "action_controller/metal/basic_implicit_render"

module RailsTwirp
  module ImplicitRender
    include ActionController::BasicImplicitRender

    def default_render
      render
    end
  end
end
