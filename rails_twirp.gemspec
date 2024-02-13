# frozen_string_literal: true

require_relative "lib/rails_twirp/version"

Gem::Specification.new do |spec|
  spec.name = "rails_twirp"
  spec.version = RailsTwirp::VERSION
  spec.authors = ["Bouke van der Bijl"]
  spec.email = ["bouke@cheddar.me"]
  spec.homepage = "https://github.com/cheddar-me/rails-twirp"
  spec.summary = "Integrate Twirp into Rails"
  spec.license = "MIT"

  spec.files = `git ls-files`.split("\n")

  # Rails has shipped an incompatible change in ActiveView, that was reverted in later versions.
  # @see https://github.com/rails/rails/pull/51023
  excluded_versions = ['7.1.0', '7.1.1', '7.1.2', '7.1.3'].map { |v| "!= #{v}" }
  spec.add_runtime_dependency 'rails', ">= 6.1.3", *excluded_versions
  spec.add_runtime_dependency "twirp", ">= 1.9", "< 1.11"
  spec.required_ruby_version = ">= 3"
end
