require 'rails_helper'
require 'test_extended_builder'
require 'another_extended_builder'

include EditInPlace

RSpec.describe ExtendedBuilder do
  let(:base_builder) { Builder.new }
  let(:extended) { TestExtendedBuilder.new(base_builder) }
  let(:extended_again) { AnotherExtendedBuilder.new(extended) }

  it 'delegates all missing methods' do
    expect(extended_again).to respond_to :field
    expect(extended_again).to respond_to :an_extension
    expect(extended_again).to respond_to :another_extension
  end
end
