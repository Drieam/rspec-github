# frozen_string_literal: true

RSpec.describe RSpec::Github do
  it 'creates an error annotation for failing specs' do
    expect(true).to eq false
  end

  it 'creates a warning annotation for pending specs'

  it 'does not create an annotiation for passing specs' do
    expect(true).to eq true
  end
end
