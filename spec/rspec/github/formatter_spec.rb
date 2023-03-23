# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RSpec::Github::Formatter do
  let(:output) { StringIO.new }
  let(:formatter) { described_class.new(output) }
  subject(:output_string) { output.string }
  let(:skip) { false }

  let(:location) { './spec/models/user_spec.rb:12' }

  let(:pending_message) { 'Not yet implemented' }

  let(:execution_result) do
    double(
      'RSpec::Core::Example::ExecutionResult',
      pending_message: pending_message
    )
  end

  let(:example) do
    double(
      'RSpec::Core::Example',
      execution_result: execution_result,
      full_description: 'User is expected to validate presence of name',
      description: 'is expected to validate presence of name',
      location: location,
      skip: skip
    )
  end

  before do
    allow(File).to receive(:realpath).and_call_original
    allow(File).to receive(:realpath).with('./spec/models/user_spec.rb')
                                     .and_return(File.join(Dir.pwd, 'spec/models/user_spec.rb'))
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

        ::error file=spec/models/user_spec.rb,line=12::#{example.full_description}%0A%0A#{notification.message_lines.join('%0A')}
      MESSAGE
    end

    context 'relative_path to GITHUB_WORKSPACE' do
      around do |example|
        saved_github_workspace = ENV.fetch('GITHUB_WORKSPACE', nil)
        ENV['GITHUB_WORKSPACE'] = tmpdir

        FileUtils.mkpath File.dirname(absolute_path)
        FileUtils.touch absolute_path

        Dir.chdir tmpdir do
          example.run
        end
      ensure
        FileUtils.rm_r tmpdir
        ENV['GITHUB_WORKSPACE'] = saved_github_workspace
      end

      let(:tmpdir) { Dir.mktmpdir }
      let(:relative_path) { 'this/is/a/relative_path.rb' }
      let(:absolute_path) { File.join(tmpdir, relative_path) }

      context 'inside root dir' do
        let(:github_workspace) { tmpdir }
        let(:location) { './this/is/a/relative_path.rb' }

        it 'returns the relative path' do
          is_expected.to include 'this/is/a/relative_path.rb'
        end
      end
      context 'inside subdirectory dir' do
        let(:github_workspace) { tmpdir }
        let(:location) { './a/relative_path.rb' }
        around do |example|
          Dir.chdir 'this/is' do
            example.run
          end
        end

        it 'returns the relative path' do
          is_expected.to include 'this/is/a/relative_path.rb'
        end
      end
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

    context 'when pending' do
      it 'outputs the GitHub annotation formatted warning' do
        is_expected.to eq <<~MESSAGE

          ::warning file=spec/models/user_spec.rb,line=12::#{example.full_description}%0A%0APending: #{pending_message}
        MESSAGE
      end
    end

    context 'when skipped' do
      let(:skip) { true }

      it 'outputs the GitHub annotation formatted warning' do
        is_expected.to eq <<~MESSAGE

          ::warning file=spec/models/user_spec.rb,line=12::#{example.full_description}%0A%0ASkipped: #{pending_message}
        MESSAGE
      end
    end
  end

  describe '#seed' do
    before { formatter.seed(notification) }

    context 'when seed used' do
      let(:notification) do
        RSpec::Core::Notifications::SeedNotification.new(4242, true)
      end

      it 'outputs the fully formatted seed notification' do
        is_expected.to eq "\nRandomized with seed 4242\n"
      end
    end

    context 'when seed not used' do
      let(:notification) do
        RSpec::Core::Notifications::SeedNotification.new(nil, false)
      end

      it { is_expected.to be_empty }
    end
  end
end
