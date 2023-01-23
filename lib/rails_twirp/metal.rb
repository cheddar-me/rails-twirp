# frozen_string_literal: true

module RailsTwirp
  # This is a simplest possible controller, providiing a valid
  # Rack interfacee witout the additional niceties provided by RailsTwirp.
  #
  # Idiologially, it's similar to Rails version of ActionController::Metal
  class Metal < AbstractController::Base
    abstract!

    include AbstractController::Helpers

    helper_method :view_cache_dependencies

    include ActionController::Caching

    # Returns the last part of the controller's name, underscored, without the ending
    # <tt>Controller</tt>. For instance, PostsController returns <tt>posts</tt>.
    # Namespaces are left out, so Admin::PostsController returns <tt>posts</tt> as well.
    #
    # ==== Returns
    # * <tt>string</tt>
    def self.controller_name
      @controller_name ||= (name.demodulize.delete_suffix("Controller").underscore unless anonymous?)
    end

    # Delegates to the class's ::controller_name.
    def controller_name
      self.class.controller_name
    end
  end
end