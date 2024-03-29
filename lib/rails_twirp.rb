# frozen_string_literal: true

require "rails_twirp/version"

require "rails_twirp/application"
require "rails_twirp/base"
require "rails_twirp/route_set"
require "rails_twirp/testing/integration_test"
require "rails_twirp/log_subscriber"

module RailsTwirp
  mattr_accessor :test_app
  mattr_accessor :unhandled_exception_handler
end

require "rails_twirp/engine" if defined?(Rails)
