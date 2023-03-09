# frozen_string_literal: true

require_relative 'lib/rspec/github/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-github'
  spec.version       = RSpec::Github::VERSION
  spec.authors       = ['Stef Schenkelaars']
  spec.email         = ['stef.schenkelaars@gmail.com']

  spec.summary       = 'Formatter for RSpec to show errors in GitHub action annotations'
  spec.description   = 'Formatter for RSpec to show errors in GitHub action annotations'
  spec.homepage      = 'https://drieam.github.io/rspec-github'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/drieam/rspec-github'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['{lib}/**/*']

  spec.add_runtime_dependency 'rspec-core', '~> 3.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.12.0'
  spec.add_development_dependency 'rubocop-ast', '~> 1.4.0'
end
