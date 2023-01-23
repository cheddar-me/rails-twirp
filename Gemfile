source "https://rubygems.org"

# Specify your gem's dependencies in rails_twirp.gemspec.
gemspec

gem "sqlite3"
gem "pbbuilder", "~> 0.13.0"
gem "standard"
gem "pry"

# HACK(bouk): Overwrite Bundler's platform matcher to ignore universal CPU
# The protobuf and gRPC 'universal' macOS gems break on M1
module Bundler::MatchPlatform
  def match_platform(p)
    return false if ::Gem::Platform === platform && platform.cpu == "universal"
    Bundler::MatchPlatform.platforms_match?(platform, p)
  end
end
