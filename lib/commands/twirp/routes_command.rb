module RailsTwirp
  module Command
    class RoutesCommand < Rails::Command::Base
      namespace "twirp"

      desc "routes", "Show Twirp routes"
      def perform
        require_application_and_environment!
        lines = [["Method", "Controller#Action"]]

        Rails.application.twirp.routes.services.each do |svc, route_set|
          route_set.rpcs.each do |name, mapping|
            lines << ["/#{svc.service_full_name}/#{name}", mapping.to_s]
          end
        end

        first_width = lines.map { |line| line[0].length }.max
        second_width = lines.map { |line| line[1].length }.max

        lines.each do |(first, second)|
          say "#{first.rjust(first_width)} #{second.ljust(second_width)}\n"
        end
      end
    end
  end
end
