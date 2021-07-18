# frozen_string_literal: true

RSpec.describe EditInPlace::MiddlewareRegistrar do
  let(:registrar) { described_class.new }

  describe '#dup' do
    let(:dup) { registrar.dup }

    it 'returns a new MiddlewareRegistrar' do
      expect(dup).to be_an_instance_of described_class
    end
  end

  describe '$register' do
    context 'with a non-middleware object' do
      def register
        registrar.register :capitalize, 'random bad object'
      end

      it 'raises an appropriate error' do
        expect { register }.to raise_error Middlegem::InvalidMiddlewareError
      end

      it 'does not register the name' do
        ignore { register }
        expect(registrar.find(:capitalize)).to be_nil
      end
    end

    context 'with a middleware class' do
      before { registrar.register :one, MiddlewareOne }

      it 'registers it' do
        expect(registrar.find(:one)).to eq MiddlewareOne
      end
    end

    context 'with a valid middleware object' do
      before { registrar.register :capitalize, ->(input) { input.upcase } }

      it 'registers it' do
        expect(registrar.find(:capitalize).call('lower')).to eq 'LOWER'
      end
    end
  end

  describe '#register_all' do
    context 'with one non-middleware object' do
      def register
        registrar.register_all({
          capitalize: proc {},
          bad: 'random object'
        })
      end

      it 'raises an appropriate error' do
        expect { register }.to raise_error Middlegem::InvalidMiddlewareError
      end

      it 'registers no middlewares' do
        ignore { register }
        expect(registrar.all).to be_empty
      end
    end
  end
end
