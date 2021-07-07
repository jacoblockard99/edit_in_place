require 'rails_helper'
require 'test_field_type'
require 'complex_test_field_type'

include EditInPlace

RSpec.describe Builder do
  before do
    # Reset the global configuration.
    EditInPlace.config = Configuration.new
  end

  subject { Builder.new }

  describe '#initialize' do
    before do
      EditInPlace.configure do |c|
        c.field_types.register(:text, TestFieldType.new('text field'))
        c.field_options.mode = :seeing
      end
    end

    it 'begins with the global configuration' do
      expect(subject.config.field_types.find(:text).arg).to eq 'text field'
      expect(subject.config.field_options.mode).to eq :seeing
    end

    it 'is not affected by further changes to the global configuration' do
      subject
      EditInPlace.config.field_types.register(:another, TestFieldType.new('another field'))
      expect(subject.config.field_types.find(:another)).to be_nil
    end
  end

  describe '#configure' do
    it 'yields the configuration' do
      subject.configure do |c|
        expect(c).to eq subject.config
      end
    end

    context 'when the configuration is changed' do
      before do
        subject.configure do |c|
          c.field_options.view = 'some view object'
        end
      end

      it 'allows the configuration to be changed' do
        expect(subject.config.field_options.view).to eq 'some view object'
      end

      it 'does not change the global configuration' do
        expect(EditInPlace.config.field_options.view).to be_nil
      end
    end
  end

  describe '#field' do
    context 'with invalid type' do
      it 'raises an appropriate error' do
        error = 'That is not a valid field type!'
        expect { subject.field('random field type', 'some', 'args') }.to raise_error error
      end
    end

    context 'with unregistered type name' do
      it 'raise an appropriate error' do
        error = 'No field types are registered with that name!'
        expect { subject.field(:random_type, 'some', 'args') }.to raise_error error
      end
    end

    context 'with a valid FieldType instance' do
      let(:field_type) { TestFieldType.new('Test!') }

      it 'renders correctly' do
        expect(subject.field(field_type, 'ARG')).to eq 'Init: Test!, After: ARG'
      end
    end

    context 'with a valid registered field type name' do
      before do
        subject.config.field_types.register(:a_new_type, TestFieldType.new('NEW TYPE'))
      end

      it 'renders correctly' do
        expect(subject.field(:a_new_type, 'Argument')).to eq 'Init: NEW TYPE, After: Argument'
      end
    end

    context 'with a field options hash' do
      it 'respects it' do
        actual = subject.field(TestFieldType.new('Test'), { mode: :editing }, 'Here')
        expect(actual).to eq 'EDITING: Init: Test, After: Here'
      end
    end

    context 'with a FieldOptions instance' do
      it 'respects it' do
        actual = subject.field(TestFieldType.new('T'), FieldOptions.new(mode: :editing), 'Here')
        expect(actual).to eq 'EDITING: Init: T, After: Here'
      end
    end

    context 'with multiple options, but no field options' do
      let(:renderer) { -> { subject.field(ComplexTestFieldType.new, 'Jacob', '**') } }

      context 'when viewing' do
        it 'renders correctly' do
          expect(renderer[]).to eq '** Jacob **'
        end
      end

      context 'when editing' do
        before { subject.config.field_options.mode = :editing }

        it 'renders correctly' do
          expect(renderer[]).to eq '||** |Jacob| **||'
        end
      end
    end
  end
end
