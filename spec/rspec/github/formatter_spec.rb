# frozen_string_literal: true

RSpec.describe RSpec::Github::Formatter do
  let(:output) { StringIO.new }
  let(:formatter) { described_class.new(output) }
  subject(:output_string) { output.string }

  let(:execution_result) do
    double(
      'RSpec::Core::Example::ExecutionResult',
      pending_message: 'Not yet implemented'
    )
  end

  let(:example) do
    double(
      'RSpec::Core::Example',
      execution_result: execution_result,
      full_description: 'User is expected to validate presence of name',
      description: 'is expected to validate presence of name',
      location: './spec/models/user_spec.rb:12'
    )
  end

  describe '#example_failed' do
    before { formatter.example_failed(notification) }

    let(:notification) do
      double(
        'RSpec::Core::Notifications::FailedExampleNotification',
        example: example,
        message_lines: [
          'Failure/Error: it { is_expected.to validate_presence_of :name }',
          '',
          '  Expected User to validate that :name cannot be empty/falsy, but this',
          '  could not be proved.',
          '    After setting :name to ‹""›, the matcher expected the User to be',
          '    invalid, but it was valid instead.'
        ]
      )
    end

    it 'outputs the GitHub annotation formatted error' do
      is_expected.to eq <<~MESSAGE
        ::error file=./spec/models/user_spec.rb,line=12::#{notification.message_lines.join('%0A')}
      MESSAGE
    end
  end

  describe '#example_pending' do
    before { formatter.example_pending(notification) }

    let(:notification) do
      double(
        'RSpec::Core::Notifications::SkippedExampleNotification',
        example: example
      )
    end

    it 'outputs the GitHub annotation formatted error' do
      is_expected.to eq <<~MESSAGE
        ::warning file=./spec/models/user_spec.rb,line=12::#{example.full_description}
      MESSAGE
    end
  end
end
