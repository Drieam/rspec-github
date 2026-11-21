# frozen_string_literal: true

require_relative './test_class.rb'

RSpec.describe RSpec::Github::Formatter do
  it 'creates an error annotation for crashing specs' do
    expect(TestClass.crash).to eq true
  end
end
