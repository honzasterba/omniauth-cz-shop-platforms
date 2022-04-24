# frozen_string_literal: true

require 'oauth2'
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    # Main class for Seznam.cz strategy.
    class Shoptet < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'basic_eshop'
      USER_INFO_PATH = '/action/OAuthServer/resource?method=getBasicEshop'

      option :name, 'shoptet'
      option :scope, DEFAULT_SCOPE

      option :client_options,
             authorize_url: '/action/OAuthServer/authorize',
             token_url: '/action/OAuthServer/token',
             auth_scheme: :request_body
      option :authorize_options, %i[scope]
      option :token_options, %i[scope]

      def client_site
        if options.site
          options.site
        elsif request.params['shop_name']
          shop_name = request.params['shop_name']
          site = "https://#{shop_name}.myshoptet.com"
          session['omniauth.shoptet.site'] = site
          site
        elsif session['omniauth.shoptet.site']
          session['omniauth.shoptet.site']
        else
          raise 'Cannot determine client site, set :site option or shop_name request param.'
        end
      end

      def client
        client_options = deep_symbolize(options.client_options)
        client_options[:site] = client_site
        ::OAuth2::Client.new(options.client_id, options.client_secret, client_options)
      end

      uid { raw_info['user']['email'] }

      info do
        {
          email: raw_info['user']['email'],
          name: raw_info['user']['name'],
          store: raw_info['project']
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def callback_url
        full_host + callback_path
      end

      def raw_info
        @raw_info ||= access_token.get(USER_INFO_PATH).parsed['data']
      end
    end
  end
end
