# frozen_string_literal: true

require 'rails_helper'
require 'support/middleware_one'

RSpec.describe EditInPlace::MiddlewareStack do
  let(:defined) { [Proc, MiddlewareOne] }
  let(:registrar) { EditInPlace::MiddlewareRegistrar.new }
  let(:stack) { described_class.new(defined, middlewares, registrar) }

  describe '#call' do
    context 'with an invalid middleware object' do
      let(:middlewares) { [proc {}, proc {}, 'random bad object', proc {}] }

      it 'raises an appropriate error' do
        expected = Middlegem::InvalidMiddlewareError
        expect { stack.call('random input') }.to raise_error expected
      end
    end

    context 'with valid middleware objects' do
      let(:middlewares) { [proc { |i| [i.upcase] }] }

      it 'transforms the input correctly' do
        expect(stack.call('lowercase')).to eq ['LOWERCASE']
      end
    end

    context 'with a valid registered middleware name' do
      before { registrar.register(:lowercase, proc { |i| [i.downcase] }) }

      let(:middlewares) { [:lowercase] }

      it 'transforms the input correctly' do
        expect(stack.call('UPPERCASE')).to eq ['uppercase']
      end
    end

    context 'with an unregistered middleware name' do
      let(:middlewares) { [:unregistered] }

      it 'raises an appropriate error' do
        expect { stack.call('input') }.to raise_error EditInPlace::UnregisteredMiddlewareError
      end
    end

    context 'with a middleware class' do
      let(:middlewares) { [MiddlewareOne] }

      it 'transforms the input correctly' do
        expect(stack.call('options', 'input')).to eq ['options', 'input*ONE*']
      end
    end
  end
end
