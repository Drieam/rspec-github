# frozen_string_literal: true

require 'bundler/setup'
require 'rspec/github'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # RSpec 4 no longer exposes its DSL globally and dropped the `should` syntax,
  # so these settings only exist (and are only needed) on RSpec 3.
  if config.respond_to?(:disable_monkey_patching!)
    # Disable RSpec exposing methods globally on `Module` and `main`
    config.disable_monkey_patching!

    config.expect_with :rspec do |c|
      c.syntax = :expect
    end
  end
end
