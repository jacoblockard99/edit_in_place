# frozen_string_literal: true

require 'support/test_object'

RSpec.describe EditInPlace::Registrar do
  let(:registrar) { described_class.new }

  describe '#dup' do
    before do
      registrar.register_all({
        first: TestObject.new('First Object', { one: 'One', two: 'Two' }),
        second: TestObject.new('Second Object')
      })
    end

    let(:dup) { registrar.dup }

    it 'duplicates the first registration' do
      expect(dup.find(:first).object_id).not_to eq registrar.find(:first).object_id
    end

    it 'duplicates the second registration' do
      expect(dup.find(:second).object_id).not_to eq registrar.find(:second).object_id
    end

    it 'performs a deep copy of the registration' do
      expect(dup.find(:first).name.object_id).not_to eq registrar.find(:first).name.object_id
    end

    it 'performs a very deep copy of the registration' do
      actual = dup.find(:first).attributes[:one].object_id
      expect(actual).not_to eq registrar.find(:first).attributes[:one].object_id
    end

    it 'copies the first registration correctly' do
      expect(dup.find(:first).attributes[:two]).to eq 'Two'
    end

    it 'copies the second registration correctly' do
      expect(dup.find(:second).name).to eq 'Second Object'
    end
  end

  describe '#register' do
    context 'with an existing name' do
      before { registrar.register :existing, 'random object' }

      it 'raises an appropriate error' do
        error = EditInPlace::DuplicateRegistrationError
        expect { registrar.register :existing, 'object' }.to raise_error error
      end

      it 'does not register the name' do
        expect(registrar.find(:existing)).to eq 'random object'
      end
    end

    context 'with a string name' do
      def register
        registrar.register 'string', 'object'
      end

      it 'raises an appropriate error' do
        expect { register }.to raise_error EditInPlace::InvalidRegistrationNameError
      end

      it 'does not register the name' do
        ignore { register }
        expect(registrar.find('string')).to be_nil
      end
    end
  end

  describe '#register_all' do
    context 'with one existing registration' do
      before { registrar.register(:example, TestObject.new('EXISTING OBJECT')) }

      def register
        registrar.register_all({
          text: TestObject.new('TEXT'),
          example: TestObject.new('EXAMPLE')
        })
      end

      it 'raise an appropriate error' do
        expect { register }.to raise_error EditInPlace::DuplicateRegistrationError
      end

      it 'registers nothing new' do
        ignore { registrar }
        expect(registrar.all.count).to eq 1
      end

      it 'does not modify the existing registration' do
        ignore { registrar }
        expect(registrar.find(:example).name).to eq 'EXISTING OBJECT'
      end
    end

    context 'with one string key' do
      def register
        registrar.register_all({
          :image => TestObject.new('IMAGE'),
          'text' => TestObject.new('TEXT')
        })
      end

      it 'raises an appropriate error' do
        expect { register }.to raise_error EditInPlace::InvalidRegistrationNameError
      end

      it 'registers nothing' do
        ignore { register }
        expect(registrar.all).to be_empty
      end
    end

    context 'with a valid hash of registrations' do
      before do
        registrar.register_all({
          text: TestObject.new('TEXT'),
          image: TestObject.new('IMAGE'),
          bool: TestObject.new('BOOL')
        })
      end

      it 'registers exactly three registrations' do
        expect(registrar.all.count).to eq 3
      end

      it 'registers the first registration correctly' do
        expect(registrar.find(:text).name).to eq 'TEXT'
      end

      it 'registers the second registration correctly' do
        expect(registrar.find(:image).name).to eq 'IMAGE'
      end

      it 'registers the third registration correctly' do
        expect(registrar.find(:bool).name).to eq 'BOOL'
      end
    end
  end

  describe '#find' do
    context 'with an existing name' do
      let(:registration) { TestObject.new('EXISTING') }

      before { registrar.register :existing, registration }

      it 'returns the associated registration' do
        expect(registrar.find(:existing)).to eq registration
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
        one: TestObject.new('ONE', { one: 'One', two: 'Two' }),
        two: TestObject.new('TWO'),
        three: MiddlewareThree
      })
    end

    let(:all) { registrar.all }

    it 'returns the correct number of registrations' do
      expect(all.count).to eq 3
    end

    it 'includes the first registered' do
      expect(all[:one].name).to eq 'ONE'
    end

    it 'includes the second registered' do
      expect(all[:two].name).to eq 'TWO'
    end

    it 'duplicates the first registration' do
      expect(all[:one].object_id).not_to eq registrar.find(:one).object_id
    end

    it 'duplicates the second registration' do
      expect(all[:two].object_id).not_to eq registrar.find(:two).object_id
    end

    it 'does not duplicate classes' do
      expect(all[:three].object_id).to eq registrar.find(:three).object_id
    end

    it 'performs a deep copy of the registrations' do
      expect(all[:one].name.object_id).not_to eq registrar.find(:one).name.object_id
    end

    it 'performs a very deep copy of the registrations' do
      actual = all[:one].attributes[:one].object_id
      expect(actual).not_to eq registrar.find(:one).attributes[:one].object_id
    end
  end
end
