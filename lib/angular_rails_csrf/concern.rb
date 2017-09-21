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
        cookie_name = self.class.default_options[:cookie_name]
        cookies[cookie_name] = form_authenticity_token
      end
    end

    def verified_request?
      header_name = self.class.default_options[:header_name]
      if respond_to?(:valid_authenticity_token?, true)
        super || valid_authenticity_token?(session, request.headers[header_name])
      else
        super || form_authenticity_token == request.headers[header_name]
      end
    end

    module ClassMethods
      def exclude_xsrf_token_cookie
        self.class_eval do
          def __exclude_xsrf_token_cookie?
            true
          end
        end
      end

      def default_options
        @default_options ||= {
            cookie_name: "XSRF-TOKEN",
            header_name: "X-XSRF-TOKEN"
        }
      end
    end

  end
end
