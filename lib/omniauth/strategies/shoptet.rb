# frozen_string_literal: true

require 'oauth2'
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    # Main class for Seznam.cz strategy.
    class Shoptet < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'basic_eshop'
      USER_INFO_PATH = '/resource?method=getBasicEshop'

      option :name, 'shoptet'
      option :authorize_options, %i[client_id scope state redirect_uri]

      option :client_options,
             authorize_url: '/authorize',
             token_url: '/token',
             auth_scheme: :request_body

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless ['', nil].member?(request.params[k.to_s])
          end
          params[:scope] ||= DEFAULT_SCOPE
          session['omniauth.state'] = params[:state] if params[:state]
        end
      end

      uid { raw_info['data']['user']['email'] }

      info do
        {
          email: raw_info['data']['user']['email'],
          store: raw_info['data']['user']['project']
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def callback_url
        full_host + callback_path
      end

      def raw_info
        @raw_info ||= access_token.get(USER_INFO_PATH).parsed
      end
    end
  end
end
