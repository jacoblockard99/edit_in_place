# frozen_string_literal: true

require 'rails_helper'
require 'support/test_field_type'
require 'support/complex_test_field_type'
require 'support/middleware_one'
require 'support/middleware_two'
require 'support/middleware_three'

RSpec.describe EditInPlace::Builder do
  let(:builder) { described_class.new }

  before do
    # Reset the global configuration.
    EditInPlace.config = EditInPlace::Configuration.new
  end

  describe '#initialize' do
    before do
      EditInPlace.configure do |c|
        c.field_types.register(:text, TestFieldType.new('text field'))
        c.field_options.mode = :seeing
      end
    end

    it 'begins with the field types of the global configuration' do
      expect(builder.config.field_types.find(:text).arg).to eq 'text field'
    end

    it 'beings with the field options of the global configuration' do
      expect(builder.config.field_options.mode).to eq :seeing
    end

    it 'is not affected by further changes to the global configuration' do
      builder
      EditInPlace.config.field_types.register(:another, TestFieldType.new('another field'))
      expect(builder.config.field_types.find(:another)).to be_nil
    end
  end

  describe '#dup' do
    before do
      builder.config.field_options.middlewares = ['example', :another]
    end
    let(:dup) { builder.dup }

    it 'returns a different instance' do
      expect(dup.object_id).not_to eq builder.object_id
    end

    it 'copies the config' do
      expect(dup.config.field_options.middlewares).to eq ['example', :another]
    end

    it 'performs a deep copy of the config' do
      actual = dup.config.field_options.middlewares[0].object_id
      expect(actual).not_to eq builder.config.field_options.middlewares[0].object_id
    end
  end

  describe '#configure' do
    it 'yields the configuration' do
      builder.configure do |c|
        expect(c).to eq builder.config
      end
    end

    context 'when the configuration is changed' do
      before do
        builder.configure do |c|
          c.field_options.view = 'some view object'
        end
      end

      it 'changes it' do
        expect(builder.config.field_options.view).to eq 'some view object'
      end

      it 'does not change the global configuration' do
        expect(EditInPlace.config.field_options.view).to be_nil
      end
    end
  end

  describe '#field' do
    context 'with invalid type' do
      it 'raises an appropriate error' do
        error = EditInPlace::InvalidFieldTypeError
        expect { builder.field('random field type', 'some', 'args') }.to raise_error error
      end
    end

    context 'with unregistered type name' do
      it 'raise an appropriate error' do
        error = EditInPlace::UnregisteredFieldTypeError
        expect { builder.field(:random_type, 'some', 'args') }.to raise_error error
      end
    end

    context 'with a valid FieldType instance' do
      let(:field_type) { TestFieldType.new('Test!') }

      it 'renders correctly' do
        expect(builder.field(field_type, 'ARG')).to eq 'Init: Test!, After: ARG'
      end
    end

    context 'with a valid registered field type name' do
      before do
        builder.config.field_types.register(:a_new_type, TestFieldType.new('NEW TYPE'))
      end

      it 'renders correctly' do
        expect(builder.field(:a_new_type, 'Argument')).to eq 'Init: NEW TYPE, After: Argument'
      end
    end

    context 'with a field options hash' do
      it 'respects it' do
        actual = builder.field(TestFieldType.new('Test'), { mode: :editing }, 'Here')
        expect(actual).to eq 'EDITING: Init: Test, After: Here'
      end
    end

    context 'with a FieldOptions instance' do
      let(:field_options) { EditInPlace::FieldOptions.new(mode: :editing) }

      it 'respects it' do
        actual = builder.field(TestFieldType.new('T'), field_options, 'Here')
        expect(actual).to eq 'EDITING: Init: T, After: Here'
      end
    end

    context 'with multiple arguments, but no field options' do
      let(:rendered) { builder.field(ComplexTestFieldType.new, 'Jacob', '**') }

      context 'when viewing' do
        it 'renders correctly' do
          expect(rendered).to eq '** Jacob **'
        end
      end

      context 'when editing' do
        before { builder.config.field_options.mode = :editing }

        it 'renders correctly' do
          expect(rendered).to eq '||** |Jacob| **||'
        end
      end
    end

    context 'with middlewares' do
      before do
        EditInPlace.configure do |c|
          c.defined_middlewares = [
            MiddlewareOne,
            MiddlewareTwo,
            MiddlewareThree
          ]
          c.field_options.middlewares << MiddlewareThree.new
        end
        builder.config.field_options.middlewares << MiddlewareOne.new
      end

      let(:field_options) { { middlewares: [MiddlewareTwo.new] } }
      let(:field_type) { TestFieldType.new('Test!') }

      it 'applies them' do
        actual = builder.field(field_type, field_options, 'ARG')
        expect(actual).to eq 'Init: Test!, After: ARG*ONE*!TWO!$THREE$'
      end
    end
  end
end
