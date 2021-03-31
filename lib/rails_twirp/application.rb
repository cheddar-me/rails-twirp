require "rails_twirp/route_set"

module RailsTwirp
  class Application
    def routes
      @routes ||= RouteSet.new
    end
  end
end
