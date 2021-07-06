require 'rails_helper'
require 'test_field_type'

include EditInPlace

RSpec.describe FieldTypeRegistrar do
  subject { FieldTypeRegistrar.new }

  describe '#dup' do
    before do
      subject.register_all({
        text: TestFieldType.new('TEXT ARG'),
        image: TestFieldType.new('IMAGE ARG')
      })
    end

    let(:dup) { subject.dup }

    it 'duplicates the field types' do
      expect(dup.find(:text).object_id).to_not eq subject.find(:text).object_id
      expect(dup.find(:image).object_id).to_not eq subject.find(:image).object_id
    end

    it 'performs a deep copy of the field types' do
      expect(dup.find(:text).arg.object_id).to_not eq subject.find(:text).arg.object_id
    end

    it 'copies all fields' do
      expect(dup.find(:text).arg).to eq 'TEXT ARG'
      expect(dup.find(:image).arg).to eq 'IMAGE ARG'
    end
  end

  describe '#register' do
    context 'with an existing name' do
      before { subject.register :existing, TestFieldType.new('EXISTING') }

      it 'raises an appropriate error' do
        error = 'That field type name has already been registered!'
        expect { subject.register :existing, 'object' }.to raise_error error
      end

      it 'does not register the name' do
        expect(subject.find(:existing).arg).to eq 'EXISTING'
      end
    end

    context 'with a string name' do
      let(:registerer) { -> { subject.register 'string', 'object' } }

      it 'raises an appropriate error' do
        expect(&registerer).to raise_error 'The name must be a symbol!'
      end

      it 'does not register the name' do
        registerer[] rescue nil
        expect(subject.find('string')).to be_nil
      end
    end

    context 'with a non-FieldType field type' do
      let(:registerer) { -> { subject.register :text, 'random bad object' } }

      it 'raises an appropriate error' do
        expect(&registerer).to raise_error 'The field type must be an instance of FieldType!'
      end

      it 'does not register the name' do
        registerer[] rescue nil
        expect(subject.find(:text)).to be_nil
      end
    end

    context 'with a valid field type that is an instance of a subclass of FieldType' do
      before { subject.register :text, TestFieldType.new('TEXT') }

      it 'registers it'do
        expect(subject.find(:text).arg).to eq 'TEXT'
      end
    end
  end

  describe '#register_all' do
    context 'with an invalid enumerable' do
      let(:registerer) { -> { subject.register_all([:valid, :keys, :but, :no, :values]) } }

      it 'raises any error' do
        expect(&registerer).to raise_error RuntimeError
      end
      
      it 'registers no field types' do
        registerer[] rescue nil
        expect(subject.all).to be_empty
      end
    end

    context 'with one existing field type' do
      before { subject.register(:image, TestFieldType.new('EXISTING IMAGE')) }

      let(:registerer) do
        lambda do
          subject.register_all({
            text: TestFieldType.new('TEXT'),
            image: TestFieldType.new('IMAGE')
          })
        end
      end

      it 'raise an appropriate error' do
        expect(&registerer).to raise_error 'That field type name has already been registered!'
      end

      it 'registers no new field types' do
        registerer[] rescue nil
        expect(subject.all.count).to eq 1
      end

      it 'does not modify the existing field type' do
        registerer[] rescue nil
        expect(subject.find(:image).arg).to eq 'EXISTING IMAGE'
      end
    end

    context 'with one string key' do
      let(:registerer) do
        lambda do
          subject.register_all({
            :image => TestFieldType.new('IMAGE'),
            'text' => TestFieldType.new('TEXT')
          })
        end
      end

      it 'raise an appropriate error' do
        expect(&registerer).to raise_error 'The name must be a symbol!'
      end

      it 'registers no field types' do
        registerer[] rescue nil
        expect(subject.all).to be_empty
      end
    end

    context 'with one non-FieldType field type' do
      let(:registerer) do
        lambda do
          subject.register_all({
            image: TestFieldType.new('IMAGE'),
            text: 'random object'
          })
        end
      end

      it 'raise an appropriate error' do
        expect(&registerer).to raise_error 'The field type must be an instance of FieldType!'
      end

      it 'registers no field types' do
        registerer[] rescue nil
        expect(subject.all).to be_empty
      end
    end

    context 'with a valid hash of field types' do
      before do
        subject.register_all({
          text: TestFieldType.new('TEXT'),
          image: TestFieldType.new('IMAGE'),
          bool: TestFieldType.new('BOOL')
        })
      end

      it 'registers exactly three field types' do
        expect(subject.all.count).to eq 3
      end

      it 'registers all the field types correctly' do
        expect(subject.find(:text).arg).to eq 'TEXT'
        expect(subject.find(:image).arg).to eq 'IMAGE'
        expect(subject.find(:bool).arg).to eq 'BOOL'
      end
    end
  end

  context '#find' do
    context 'with an existing name' do
      let(:field_type) { TestFieldType.new('EXISTING') }
      before { subject.register :existing, field_type }

      it 'returns the associated field type' do
        expect(subject.find(:existing)).to eq field_type
      end
    end

    context 'with a non-existent name' do
      it 'returns nil' do
        expect(subject.find(:nonexistent)).to be_nil
      end
    end
  end

  context '#all' do
    before do
      subject.register_all({
        one: TestFieldType.new('ONE'),
        two: TestFieldType.new('TWO'),
        three: TestFieldType.new('THREE')
      })
    end
    let(:all) { subject.all }

    it 'returns the correct number of field types' do
      expect(all.count).to eq 3
    end

    it 'returns all registered field types' do
      expect(all[:one].arg).to eq 'ONE'
      expect(all[:two].arg).to eq 'TWO'
      expect(all[:three].arg).to eq 'THREE'
    end

    it 'duplicates the field' do
      expect(all[:one].object_id).to_not eq subject.find(:one).object_id
      expect(all[:two].object_id).to_not eq subject.find(:two).object_id
      expect(all[:three].object_id).to_not eq subject.find(:three).object_id
    end

    it 'performs a deep copy of the field types' do
      expect(all[:one].arg.object_id).to_not eq subject.find(:one).arg.object_id
    end
  end
end
