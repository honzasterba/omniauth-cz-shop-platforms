# frozen_string_literal: true

require 'oauth2'
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    # Main class for Seznam.cz strategy.
    class WebAreal < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'USER_INFO'
      USER_INFO_URL = 'https://marketplace.webareal.cz/api/user/about'

      option :name, 'web_areal'
      option :authorize_options, %i[scope]
      option :scope, DEFAULT_SCOPE

      option :client_options,
             site: 'https://marketplace.webareal.cz',
             authorize_url: '/user-auth',
             token_url: '/api/token',
             auth_scheme: :request_body

      uid { raw_info['user'] }

      info do
        {
          email: raw_info['user'],
          stores: raw_info['stores']
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def callback_url
        full_host + callback_path
      end

      def raw_info
        @raw_info ||= access_token.get(USER_INFO_URL).parsed
      end
    end
  end
end
