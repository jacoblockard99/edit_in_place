# frozen_string_literal: true

require 'spec_helper'
require 'support/test_field_type'

RSpec.describe EditInPlace::FieldTypeRegistrar do
  let(:registrar) { described_class.new }

  describe '#dup' do
    let(:dup) { registrar.dup }

    it 'returns a new FieldTypeRegistrar' do
      expect(dup).to be_an_instance_of described_class
    end
  end

  describe '#register' do
    context 'with a non-FieldType field type' do
      def register
        registrar.register :text, 'random bad object'
      end

      it 'raises an appropriate error' do
        expect { register }.to raise_error EditInPlace::InvalidFieldTypeError
      end

      it 'does not register the name' do
        ignore { register }
        expect(registrar.find(:text)).to be_nil
      end
    end

    context 'with a valid field type that is an instance of a subclass of FieldType' do
      before { registrar.register :text, TestFieldType.new('TEXT') }

      it 'registers it' do
        expect(registrar.find(:text).arg).to eq 'TEXT'
      end
    end
  end

  describe '#register_all' do
    context 'with one non-FieldType field type' do
      def register
        registrar.register_all({
          image: TestFieldType.new('IMAGE'),
          text: 'random object'
        })
      end

      it 'raise an appropriate error' do
        expect { register }.to raise_error EditInPlace::InvalidFieldTypeError
      end

      it 'registers no field types' do
        ignore { register }
        expect(registrar.all).to be_empty
      end
    end
  end
end
