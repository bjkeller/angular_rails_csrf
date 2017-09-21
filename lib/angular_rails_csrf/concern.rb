module AngularRailsCsrf
  module Concern
    extend ActiveSupport::Concern

    included do
      if Rails::VERSION::MAJOR < 4
        after_filter :set_xsrf_token_cookie
      else
        after_action :set_xsrf_token_cookie
      end
    end

    def set_xsrf_token_cookie
      if protect_against_forgery? && !respond_to?(:__exclude_xsrf_token_cookie?)
        cookies[AngularRailsCsrf::Concern.configuration.cookie_name] = form_authenticity_token
      end
    end

    def verified_request?
      if respond_to?(:valid_authenticity_token?, true)
        super || valid_authenticity_token?(session, request.headers[AngularRailsCsrf::Concern.configuration.header_name])
      else
        super || form_authenticity_token == request.headers[AngularRailsCsrf::Concern.configuration.header_name]
      end
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield configuration
    end

    module ClassMethods
      def exclude_xsrf_token_cookie
        self.class_eval do
          def __exclude_xsrf_token_cookie?
            true
          end
        end
      end
    end

    class Configuration
      include ActiveSupport::Configurable

      config_accessor :cookie_name do
        "XSRF-TOKEN"
      end

      config_accessor :header_name do
        "X-XSRF-TOKEN"
      end
    end
  end
end
