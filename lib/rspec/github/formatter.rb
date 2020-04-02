# frozen_string_literal: true

require 'rspec/core/formatters/documentation_formatter'

module RSpec
  module Github
    class Formatter < RSpec::Core::Formatters::DocumentationFormatter
      RSpec::Core::Formatters.register self, :example_failed, :example_pending

      def example_failed(failure)
        super
        file, line = failure.example.location.split(':')
        output.puts "::error file=#{file},line=#{line}::#{failure.message_lines.join('%0A')}"
      end

      def example_pending(pending)
        super
        file, line = pending.example.location.split(':')
        output.puts "::warning file=#{file},line=#{line}::#{pending.example.full_description}"
      end
    end
  end
end
