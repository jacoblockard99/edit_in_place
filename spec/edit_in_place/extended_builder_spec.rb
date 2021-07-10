# frozen_string_literal: true

require 'rails_helper'
require 'support/test_extended_builder'
require 'support/another_extended_builder'

RSpec.describe EditInPlace::ExtendedBuilder do
  let(:base_builder) { EditInPlace::Builder.new }
  let(:extended) { TestExtendedBuilder.new(base_builder) }
  let(:extended_again) { AnotherExtendedBuilder.new(extended) }

  it 'delegates methods from the base builder' do
    expect(extended_again).to respond_to :field
  end
  
  it 'delegates methods from the middle builder' do
    expect(extended_again).to respond_to :an_extension
  end

  it 'responds to methods on the actual builder' do
    expect(extended_again).to respond_to :another_extension
  end
end
