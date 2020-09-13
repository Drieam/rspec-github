# frozen_string_literal: true

require 'rspec/core'
require 'rspec/core/formatters/base_formatter'
require 'rspec/github/example_decorator'

module RSpec
  module Github
    class Formatter < RSpec::Core::Formatters::BaseFormatter
      RSpec::Core::Formatters.register self, :example_failed, :example_pending

      def example_failed(failure)
        example = ExampleDecorator.new(failure)

        output.puts "\n::error file=#{example.path},line=#{example.line}::#{example.annotation}"
      end

      def example_pending(pending)
        example = ExampleDecorator.new(pending)

        output.puts "\n::warning file=#{example.path},line=#{example.line}::#{example.annotation}"
      end
    end
  end
end
