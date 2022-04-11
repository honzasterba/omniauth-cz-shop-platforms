# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'omniauth-cz-shop-platforms'
require 'stringio'

describe OmniAuth::Strategies::Shoptet do
  let(:request) { double('Request', params: @params || {}, cookies: {}, env: { 'rack.session' => @session || {} }) }
  let(:app) do
    lambda do
      [200, {}, ['Hello.']]
    end
  end

  subject do
    OmniAuth::Strategies::Shoptet.new(app, 'appid', 'secret', @options || {}).tap do |strategy|
      allow(strategy).to receive(:request) do
        request
      end
      allow(strategy).to receive(:session) do
        request.env['rack.session']
      end
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe 'missing site information' do
    it 'should raise error' do
      expect { subject.client }.to raise_error(/Cannot determine client site/)
    end
  end

  describe 'site override' do
    before do
      @options = { site: 'https://custom.site' }
    end

    it 'has site from options' do
      expect(subject.client.site).to eq('https://custom.site')
    end
  end

  describe 'on authorize' do
    before do
      @params = { 'shop_name' => 'awesome-shop' }
    end

    describe '#client_options' do
      it 'has correct authorize_url' do
        expect(subject.client.options[:authorize_url]).to eq('/action/OAuthServer/authorize')
      end

      it 'has correct token_url' do
        expect(subject.client.options[:token_url]).to eq('/action/OAuthServer/token')
      end

      it 'has site from request param' do
        expect(subject.client.site).to eq('https://awesome-shop.myshoptet.com')
      end

      describe 'overrides' do
        it 'should allow overriding the authorize_url' do
          @options = { client_options: { 'authorize_url' => 'https://example.com' } }
          expect(subject.client.options[:authorize_url]).to eq('https://example.com')
        end

        it 'should allow overriding the token_url' do
          @options = { client_options: { 'token_url' => 'https://example.com' } }
          expect(subject.client.options[:token_url]).to eq('https://example.com')
        end
      end
    end
  end

  describe '#authorize_params' do
    it 'should include any authorize params passed in the :authorize_params option' do
      @options = { authorize_params: { request_visible_actions: 'something', foo: 'bar', baz: 'zip' }, hd: 'wow', bad: 'not_included' }
      expect(subject.authorize_params['request_visible_actions']).to eq('something')
      expect(subject.authorize_params['foo']).to eq('bar')
      expect(subject.authorize_params['baz']).to eq('zip')
      expect(subject.authorize_params['bad']).to eq(nil)
    end
  end

  describe 'token phase' do
    before do
      @session = { 'omniauth.shoptet.site' => 'SITE_SESSION' }
    end

    it 'should take client site from session' do
      expect(subject.client.site).to eq('SITE_SESSION')
    end
  end

  describe '#token_params' do
    it 'should include any token params passed in the :token_params option' do
      @options = { token_params: { foo: 'bar', baz: 'zip' } }
      expect(subject.token_params['foo']).to eq('bar')
      expect(subject.token_params['baz']).to eq('zip')
    end
  end

  describe '#token_options' do
    it 'should include top-level options that are marked as :token_options' do
      @options = { token_options: %i[scope foo], scope: 'bar', foo: 'baz', bad: 'not_included' }
      expect(subject.token_params['scope']).to eq('bar')
      expect(subject.token_params['foo']).to eq('baz')
      expect(subject.token_params['bad']).to eq(nil)
    end
  end
end
