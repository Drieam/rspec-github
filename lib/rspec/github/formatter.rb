# frozen_string_literal: true

require 'rspec/core'
require 'rspec/core/formatters/base_formatter'

module RSpec
  module Github
    class Formatter < RSpec::Core::Formatters::BaseFormatter
      RSpec::Core::Formatters.register self, :example_failed, :example_pending

      def example_failed(failure)
        file, line = failure.example.location.split(':')
        output.puts "\n::error file=#{file},line=#{line}::#{failure.message_lines.join('%0A')}"
      end

      def example_pending(pending)
        return if pending_disabled?

        file, line = pending.example.location.split(':')
        output.puts "\n::warning file=#{file},line=#{line}::#{pending.example.full_description}"
      end

      def pending_disabled?
        !ENV['RSPEC_GITHUB_DISABLE_PENDING'].nil?
      end
    end
  end
end
