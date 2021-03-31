require "rails_twirp/version"

require "rails_twirp/base"
require "rails_twirp/route_set"
require "rails_twirp/testing/integration_test"

module RailsTwirp
  mattr_accessor :test_app
end

require "rails_twirp/engine" if defined?(Rails)
