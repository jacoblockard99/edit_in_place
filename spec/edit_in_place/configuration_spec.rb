# frozen_string_literal: true
require 'rails_helper'
require 'support/test_field_type'

RSpec.describe EditInPlace::Configuration do
  let(:config) { described_class.new }

  describe '#initialize' do
    it 'sets up a blank FieldTypeRegistrar' do
      expect(config.field_types.all).to be_empty
    end

    it 'sets up a FieldOptions with a nil view context' do
      expect(config.field_options.view).to be_nil
    end

    it 'sets up a FieldOptions with the default mode' do
      expect(config.field_options.mode).to eq described_class::DEFAULT_MODE
    end
  end

  describe '#dup' do
    before do
      config.field_types.register_all({
        text: TestFieldType.new('text field'),
        image: TestFieldType.new('image field'),
        bool: TestFieldType.new('bool field')
      })
    end

    let(:dup) { config.dup }

    it 'returns a different instance' do
      expect(dup.object_id).not_to eq config.object_id
    end

    it 'duplicates the FieldTypeRegistrar' do
      expect(dup.field_types.object_id).not_to eq config.field_types.object_id
    end

    it 'duplicates the FieldOptions' do
      expect(dup.field_options.object_id).not_to eq config.field_options.object_id
    end

    it 'performs a deep copy of the FieldTypeRegistrar' do
      actual = dup.field_types.find(:text).object_id
      expect(actual).not_to eq config.field_types.find(:text).object_id
    end

    it 'can be safely modified' do
      dup.field_types.register(:new, TestFieldType.new('NEW'))
      expect(config.field_types.find(:new)).to be_nil
    end
  end
end
