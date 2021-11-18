# RailsTwirp
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails_twirp'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install rails_twirp
```

## Installing correct protobuf version for M1 Mac Chips

If you run into an issue with protobuf universal-darwin version, please paste this in your Gemfile as recommended by @bouke :

```ruby
# HACK(bouk): Overwrite Bundler's platform matcher to ignore universal CPU
# The protobuf and gRPC 'universal' macOS gems break on M1
module Bundler::MatchPlatform
  def match_platform(p)
    return false if ::Gem::Platform === platform && platform.cpu == "universal"
    Bundler::MatchPlatform.platforms_match?(platform, p)
  end
end
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
