require 'rails_helper'
require 'edit_in_place'

include EditInPlace

RSpec.describe FieldOptions do
  subject { FieldOptions.new }

  describe '#initialize' do
    context 'when given options' do
      subject { FieldOptions.new(mode: :example, view: 'random object') }

      it 'sets the mode' do
        expect(subject.mode).to eq :example
      end

      it 'sets the view' do
        expect(subject.view).to eq 'random object'
      end
    end

    context 'when given a string mode' do
      subject { FieldOptions.new(mode: 'example') }

      it 'is converted to a symbol' do
        expect(subject.mode).to eq :example
      end
    end

    context 'when given a nil mode' do
      subject { FieldOptions.new(mode: nil) }

      it 'sets the mode to nil' do
        expect(subject.mode).to be_nil
      end
    end
  end

  describe '#mode=' do
    context 'when given a string mode' do
      it 'is converted to a symbol' do
        subject.mode = 'example'
        expect(subject.mode).to eq :example
      end
    end

    context 'when given nil' do
      it 'sets the mode to nil' do
        subject.mode = nil
        expect(subject.mode).to be_nil
      end
    end
  end
end
