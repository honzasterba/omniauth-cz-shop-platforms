# frozen_string_literal: true

require File.expand_path(
  File.join('..', 'lib', 'omniauth', 'cz_shop_platforms', 'version'),
  __FILE__
)

Gem::Specification.new do |gem|
  gem.name          = 'omniauth-cz-shop-platforms'
  gem.version       = OmniAuth::CzShopPlatforms::VERSION
  gem.license       = 'MIT'
  gem.summary       = %(A collection of strategies for OmniAuth)
  gem.description   = %(This allows you to login via multiple Czech e-commerce platforms with your ruby app.)
  gem.authors       = ['Jan Sterba']
  gem.email         = ['info@jansterba.com']
  gem.homepage      = 'https://github.com/honzasterba/omniauth-cz-shop-platforms'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 3.0'

  gem.add_runtime_dependency 'oauth2', '< 2'
  gem.add_runtime_dependency 'omniauth', '~> 2.0'
  gem.add_runtime_dependency 'omniauth-oauth2', '< 2'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
end
