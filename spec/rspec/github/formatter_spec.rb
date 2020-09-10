# frozen_string_literal: true

require 'tmpdir'

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

  before do
    allow(File).to receive(:realpath).and_call_original
    allow(File).to receive(:realpath).with('./spec/models/user_spec.rb')
                                     .and_return(File.join(Dir.pwd, 'spec/models/user_spec.rb'))
  end

  describe '::relative_path' do
    around do |example|
      saved_github_workspace = ENV['GITHUB_WORKSPACE']
      ENV['GITHUB_WORKSPACE'] = github_workspace

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

    context 'if GITHUB_WORKSPACE is set' do
      let(:github_workspace) { tmpdir }

      it 'returns the path relative to it when already inside it' do
        expect(described_class.relative_path('this/is/a/relative_path.rb')).to eq('this/is/a/relative_path.rb')
      end

      it 'returns the path relative to it when in a subdirectory of it' do
        Dir.chdir 'this/is' do
          expect(described_class.relative_path('a/relative_path.rb')).to eq('this/is/a/relative_path.rb')
        end
      end
    end

    context 'if GITHUB_WORKSPACE is unset' do
      let(:github_workspace) { nil }

      it 'returns the unchanged relative path' do
        expect(described_class.relative_path('this/is/a/relative_path.rb')).to eq 'this/is/a/relative_path.rb'
      end

      it 'returns the relative path without a ./ prefix' do
        expect(described_class.relative_path('./this/is/a/relative_path.rb')).to eq 'this/is/a/relative_path.rb'
      end
    end
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

        ::error file=spec/models/user_spec.rb,line=12::#{notification.message_lines.join('%0A')}
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

        ::warning file=spec/models/user_spec.rb,line=12::#{example.full_description}
      MESSAGE
    end
  end
end
