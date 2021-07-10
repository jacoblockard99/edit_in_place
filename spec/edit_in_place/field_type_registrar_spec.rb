# frozen_string_literal: true

require 'rails_helper'
require 'support/test_field_type'

RSpec.describe EditInPlace::FieldTypeRegistrar do
  let(:registrar) { described_class.new }

  def safe
    yield if block_given?
  rescue EditInPlace::Error
    nil
  end

  describe '#dup' do
    before do
      registrar.register_all({
        text: TestFieldType.new('TEXT ARG'),
        image: TestFieldType.new('IMAGE ARG')
      })
    end

    let(:dup) { registrar.dup }

    it 'duplicates the first field type' do
      expect(dup.find(:text).object_id).not_to eq registrar.find(:text).object_id
    end

    it 'duplicates the second field type' do
      expect(dup.find(:image).object_id).not_to eq registrar.find(:image).object_id
    end

    it 'performs a deep copy of the field types' do
      expect(dup.find(:text).arg.object_id).not_to eq registrar.find(:text).arg.object_id
    end

    it 'copies the first field type correctly' do
      expect(dup.find(:text).arg).to eq 'TEXT ARG'
    end

    it 'copies the second field type correctly' do
      expect(dup.find(:image).arg).to eq 'IMAGE ARG'
    end
  end

  describe '#register' do
    context 'with an existing name' do
      before { registrar.register :existing, TestFieldType.new('EXISTING') }

      it 'raises an appropriate error' do
        error = EditInPlace::DuplicateFieldTypeRegistrationError
        expect { registrar.register :existing, 'object' }.to raise_error error
      end

      it 'does not register the name' do
        expect(registrar.find(:existing).arg).to eq 'EXISTING'
      end
    end

    context 'with a string name' do
      def register
        registrar.register 'string', 'object'
      end

      it 'raises an appropriate error' do
        expect { register }.to raise_error EditInPlace::InvalidFieldTypeNameError
      end

      it 'does not register the name' do
        safe { register }
        expect(registrar.find('string')).to be_nil
      end
    end

    context 'with a non-FieldType field type' do
      def register
        registrar.register :text, 'random bad object'
      end

      it 'raises an appropriate error' do
        expect { register }.to raise_error EditInPlace::InvalidFieldTypeError
      end

      it 'does not register the name' do
        safe { register }
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
    context 'with an invalid enumerable' do
      def register
        registrar.register_all(%i[valid keys but no values])
      end

      it 'raises any error' do
        expect { register }.to raise_error EditInPlace::InvalidFieldTypeError
      end

      it 'registers no field types' do
        safe { register }
        expect(registrar.all).to be_empty
      end
    end

    context 'with one existing field type' do
      before { registrar.register(:image, TestFieldType.new('EXISTING IMAGE')) }

      def register
        registrar.register_all({
          text: TestFieldType.new('TEXT'),
          image: TestFieldType.new('IMAGE')
        })
      end

      it 'raise an appropriate error' do
        expect { register }.to raise_error EditInPlace::DuplicateFieldTypeRegistrationError
      end

      it 'registers no new field types' do
        safe { registrar }
        expect(registrar.all.count).to eq 1
      end

      it 'does not modify the existing field type' do
        safe { registrar }
        expect(registrar.find(:image).arg).to eq 'EXISTING IMAGE'
      end
    end

    context 'with one string key' do
      def register
        registrar.register_all({
          :image => TestFieldType.new('IMAGE'),
          'text' => TestFieldType.new('TEXT')
        })
      end

      it 'raises an appropriate error' do
        expect { register }.to raise_error EditInPlace::InvalidFieldTypeNameError
      end

      it 'registers no field types' do
        safe { register }
        expect(registrar.all).to be_empty
      end
    end

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
        safe { register }
        expect(registrar.all).to be_empty
      end
    end

    context 'with a valid hash of field types' do
      before do
        registrar.register_all({
          text: TestFieldType.new('TEXT'),
          image: TestFieldType.new('IMAGE'),
          bool: TestFieldType.new('BOOL')
        })
      end

      it 'registers exactly three field types' do
        expect(registrar.all.count).to eq 3
      end

      it 'registers the first field type correctly' do
        expect(registrar.find(:text).arg).to eq 'TEXT'
      end

      it 'registers the second field type correctly' do
        expect(registrar.find(:image).arg).to eq 'IMAGE'
      end

      it 'registers the third field type correctly' do
        expect(registrar.find(:bool).arg).to eq 'BOOL'
      end
    end
  end

  describe '#find' do
    context 'with an existing name' do
      let(:field_type) { TestFieldType.new('EXISTING') }

      before { registrar.register :existing, field_type }

      it 'returns the associated field type' do
        expect(registrar.find(:existing)).to eq field_type
      end
    end

    context 'with a non-existent name' do
      it 'returns nil' do
        expect(registrar.find(:nonexistent)).to be_nil
      end
    end
  end

  describe '#all' do
    before do
      registrar.register_all({
        one: TestFieldType.new('ONE'),
        two: TestFieldType.new('TWO')
      })
    end

    let(:all) { registrar.all }

    it 'returns the correct number of field types' do
      expect(all.count).to eq 2
    end

    it 'includes the first registered field type' do
      expect(all[:one].arg).to eq 'ONE'
    end

    it 'includes the second registered field type' do
      expect(all[:two].arg).to eq 'TWO'
    end

    it 'duplicates the first field type' do
      expect(all[:one].object_id).not_to eq registrar.find(:one).object_id
    end

    it 'duplicates the second field type' do
      expect(all[:two].object_id).not_to eq registrar.find(:two).object_id
    end

    it 'performs a deep copy of the field types' do
      expect(all[:one].arg.object_id).not_to eq registrar.find(:one).arg.object_id
    end
  end
end
