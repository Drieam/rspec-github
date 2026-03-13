# frozen_string_literal: true

require 'bundler/setup'
require 'rspec/github'
require 'rspec/core/version'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Only perform this setup when running RSpec 3
  if Gem::Requirement.new('~> 3.0').satisfied_by?(Gem::Version.new(RSpec::Core::Version::STRING))
    # Disable RSpec exposing methods globally on `Module` and `main`
    config.disable_monkey_patching!

    config.expect_with :rspec do |c|
      c.syntax = :expect
    end
  end
end
