# frozen_string_literal: true

require_relative 'lib/capistrano/payloadcms/version'

Gem::Specification.new do |spec|
  spec.name = 'capistrano-payloadcms'
  spec.version = Capistrano::Payloadcms::VERSION
  spec.authors = ['Florian Crusius']
  spec.email = ['florian@zauberware.com']
  spec.description = 'Payload CMS integration for Capistrano with systemd support, enabling automated deployment and service management for Payload CMS applications using pnpm'
  spec.summary = 'Payload CMS integration for Capistrano'
  spec.homepage = 'https://github.com/zauberware/capistrano-payloadcms'
  spec.license = 'LGPL-3.0'

  spec.required_ruby_version = '>= 3.2.7'

  spec.files = Dir.glob('lib/**/*') + %w[README.md CHANGELOG.md LICENSE.txt]
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '~> 3.9', '>= 3.9.0'
  spec.add_dependency 'capistrano-pnpm', '~> 1.0'

  spec.add_development_dependency 'rake', '~> 13.0'
end
