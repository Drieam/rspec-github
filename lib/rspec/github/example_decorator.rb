# frozen_string_literal: true

require 'delegate'

module RSpec
  module Github
    class ExampleDecorator < SimpleDelegator
      # See https://github.community/t/set-output-truncates-multiline-strings/16852/3.
      ESCAPE_MAP = {
        '%' => '%25',
        "\n" => '%0A',
        "\r" => '%0D'
      }.freeze

      def line
        example.location.split(':')[1]
      end

      def annotation
        "#{example.full_description}\n\n#{message}"
          .gsub(Regexp.union(ESCAPE_MAP.keys), ESCAPE_MAP)
      end

      def path
        File.realpath(raw_path).delete_prefix("#{workspace}#{File::SEPARATOR}")
      end

      private

      def message
        if respond_to? :message_lines
          message_lines.join("\n")
        else
          "#{example.skip ? 'Skipped' : 'Pending'}: #{example.execution_result.pending_message}"
        end
      end

      def raw_path
        example.location.split(':')[0]
      end

      def workspace
        File.realpath(ENV.fetch('GITHUB_WORKSPACE', '.'))
      end
    end
  end
end
