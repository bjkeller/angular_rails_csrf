require 'angular_rails_csrf/concern'

module AngularRailsCsrf
  class Railtie < ::Rails::Railtie
    initializer 'angular-rails-csrf' do |app|
      ActiveSupport.on_load(:action_controller) do
        include AngularRailsCsrf::Concern
      end

      if app.config.respond_to?(:angular_rails_csrf_options)
        AngularRailsCsrf::Concern.default_options.merge!(app.config.angular_rails_csrf_options)
      end
    end
  end
end
