# frozen_string_literal: true

RSpec.describe RSpec::Github do
  it 'has a predefined version since this will be changed by the release action' do
    expect(described_class::VERSION).to eq '1.0.0.develop'
  end
end
