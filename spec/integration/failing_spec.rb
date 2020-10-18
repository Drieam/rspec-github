# frozen_string_literal: true

RSpec.describe RSpec::Github::Formatter do
  it 'creates an error annotation for failing specs' do
    expect(true).to eq false
  end

  it 'creates a warning annotation for unimplemented specs'

  it 'creates a warning annotation for pending specs' do
    pending 'because it is failing'
    raise
  end

  it 'creates a warning annotation for skipped specs' do
    skip 'because reasons'
  end

  it 'does not create an annotiation for passing specs' do
    expect(true).to eq true
  end

  describe 'display all annotations' do
    (1..500).each do |number|
      it "test #{number}" do
        expect(true).to eq false
      end
    end
  end
end
