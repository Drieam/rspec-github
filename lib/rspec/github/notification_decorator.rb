# frozen_string_literal: true

require 'json'

module RSpec
  module Github
    class NotificationDecorator
      # See https://github.community/t/set-output-truncates-multiline-strings/16852/3.
      ESCAPE_MAP = {
        '%' => '%25',
        "\n" => '%0A',
        "\r" => '%0D'
      }.freeze

      def initialize(notification)
        @notification = notification
      end

      def line
        example.location.split(':')[1]
      end

      def annotation
        [example.full_description, message, file_url].compact.join("\n\n")
                                                     .gsub(Regexp.union(ESCAPE_MAP.keys), ESCAPE_MAP)
      end

      # Link to the spec file at the failing line in the tested revision. The annotation itself
      # links to the commit view, which does not show files that were not changed in that commit.
      def file_url
        server_url = ENV.fetch('GITHUB_SERVER_URL', nil)
        repository = ENV.fetch('GITHUB_REPOSITORY', nil)
        sha = commit_sha
        return if [server_url, repository, sha].any? { |value| value.nil? || value.empty? }

        "#{server_url}/#{repository}/blob/#{sha}/#{path}#L#{line}"
      end

      def path
        # TODO: use `delete_prefix` when dropping ruby 2.4 support
        File.realpath(raw_path).sub(/\A#{workspace}#{File::SEPARATOR}/, '')
      end

      private

      def example
        @notification.example
      end

      def message
        if @notification.respond_to?(:message_lines)
          @notification.message_lines.join("\n")
        else
          "#{example.skip ? 'Skipped' : 'Pending'}: #{example.execution_result.pending_message}"
        end
      end

      def raw_path
        example.location.split(':')[0]
      end

      # On pull_request events GITHUB_SHA is a temporary merge commit, so prefer the PR head commit.
      def commit_sha
        pull_request_head_sha || ENV.fetch('GITHUB_SHA', nil)
      end

      def pull_request_head_sha
        event_path = ENV.fetch('GITHUB_EVENT_PATH', nil)
        return unless event_path && File.file?(event_path)

        JSON.parse(File.read(event_path)).dig('pull_request', 'head', 'sha')
      rescue JSON::ParserError
        nil
      end

      def workspace
        File.realpath(ENV.fetch('GITHUB_WORKSPACE', '.'))
      end
    end
  end
end
