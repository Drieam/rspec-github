# frozen_string_literal: true

require 'octokit'
require 'rspec/core'
require 'rspec/core/formatters/base_formatter'

module RSpec
  module Github
    class Annotator < RSpec::Core::Formatters::BaseFormatter
      RSpec::Core::Formatters.register self, :start, :dump_failures, :dump_pending, :close

      REQUIRED_ENV_VARIABLES = %w[OCTOKIT_ACCESS_TOKEN GITHUB_REPOSITORY GITHUB_SHA]

      def start(notification)
        missing_env_variables = REQUIRED_ENV_VARIABLES - ENV.keys
        raise "Missing environment variables: #{missing_env_variables}" if missing_env_variables.any?

        # Call check_run to create the pending check run
        check_run
      end

      def dump_failures(examples_notification)
        @failures = examples_notification.failure_notifications
      end

      def dump_pending(examples_notification)
        @pending = examples_notification.pending_notifications
      end

      def close(null_notification)
        annotations.each_slice(50) do |annotations_group|
          octokit_client.update_check_run(
            ENV.fetch('GITHUB_REPOSITORY'),
            check_run.id,
            status: 'completed',
            conclusion: conclusion,
            output: {
              title: 'RSpec output',
              summary: 'RSpec output',
              annotations: annotations_group
            },
            accept: Octokit::Preview::PREVIEW_TYPES[:checks]
          )
        end
      end

      private

      def conclusion
        return 'failure' if @failures.any?
        return 'neutral' if @pending.any?

        'success'
      end

      def annotations
        (@failures + @pending).map do |notification|
          NotificationDecorator.new(notification)
        end
      end

      def check_run
        @check_run ||= octokit_client.create_check_run(
          ENV.fetch('GITHUB_REPOSITORY'),
          'RSpec',
          ENV.fetch('GITHUB_SHA'),
          status: 'in_progress',
          accept: Octokit::Preview::PREVIEW_TYPES[:checks]
        )
      end

      def octokit_client
        @octokit_client ||= Octokit::Client.new
      end
    end
  end
end
