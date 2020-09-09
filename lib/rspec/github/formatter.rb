# frozen_string_literal: true

require 'rspec/core'
require 'rspec/core/formatters/base_formatter'

module RSpec
  module Github
    class Formatter < RSpec::Core::Formatters::BaseFormatter
      RSpec::Core::Formatters.register self, :example_failed, :example_pending

      def self.relative_path(path)
        workspace = File.realpath(ENV.fetch('GITHUB_WORKSPACE', '.'))
        File.realpath(path).delete_prefix("#{workspace}#{File::SEPARATOR}")
      end

      def example_failed(failure)
        file, line = failure.example.location.split(':')
        file = self.class.relative_path(file)
        output.puts "\n::error file=#{file},line=#{line}::#{failure.message_lines.join('%0A')}"
      end

      def example_pending(pending)
        file, line = pending.example.location.split(':')
        file = self.class.relative_path(file)
        output.puts "\n::warning file=#{file},line=#{line}::#{pending.example.full_description}"
      end
    end
  end
end
