require 'rails_helper'

include EditInPlace

RSpec.describe Configuration do
  subject { Configuration.new }

  describe '#initialize' do
    it 'sets up a blank FieldTypeRegistrar' do
      expect(subject.field_types.all).to be_empty
    end

    it 'sets up a FieldOptions with a nil view context' do
      expect(subject.field_options.view).to be_nil
    end

    it 'sets up a FieldOptions with the default mode' do
      expect(subject.field_options.mode).to eq Configuration::DEFAULT_MODE
    end
  end

  describe '#dup' do
    before do
      subject.field_types.register_all({
        text: TestFieldType.new('text field'),
        image: TestFieldType.new('image field'),
        bool: TestFieldType.new('bool field')
      })
    end

    let(:dup) { subject.dup }

    it 'returns a different instance' do
      expect(dup.object_id).to_not eq subject.object_id
    end

    it 'duplicates the FieldTypeRegistrar' do
      expect(dup.field_types.object_id).to_not eq subject.field_types.object_id
    end

    it 'duplicates the FieldOptions' do
      expect(dup.field_options.object_id).to_not eq subject.field_options.object_id
    end

    it 'performs a deep copy of the FieldTypeRegistrar' do
      actual = dup.field_types.find(:text).object_id
      expect(actual).to_not eq subject.field_types.find(:text).object_id
    end

    it 'can be safely modified' do
      dup.field_types.register(:new, TestFieldType.new('NEW'))
      expect(dup.field_types.find(:new).arg).to eq 'NEW'
      expect(subject.field_types.find(:new)).to be_nil
    end
  end
end
