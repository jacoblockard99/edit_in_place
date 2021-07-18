# frozen_string_literal: true

require 'support/middleware_one'

RSpec.describe EditInPlace::MiddlewareParser do
  let(:registrar) { EditInPlace::MiddlewareRegistrar.new }
  let(:parser) { described_class.new(registrar) }
  let(:middleware) { proc {} }
  let(:parsed) { parser.parse(middlewares) }

  context 'with a valid registered middleware name' do
    before { registrar.register(:lowercase, middleware) }

    let(:middlewares) { [:lowercase] }

    it 'retrieves the correct instance' do
      expect(parsed).to eq [middleware]
    end
  end

  context 'with an unregistered middleware name' do
    let(:middlewares) { [:unregistered] }

    it 'raises an appropriate error' do
      expect { parsed }.to raise_error EditInPlace::UnregisteredMiddlewareError
    end
  end

  context 'with a middleware class' do
    let(:middlewares) { [MiddlewareOne] }

    it 'converts it to an instance' do
      expect(parsed.first).to be_an_instance_of MiddlewareOne
    end
  end

  context 'with a registered middleware class' do
    before { registrar.register :one, MiddlewareOne }

    let(:middlewares) { [:one] }

    it 'converts it to an appropriate instance' do
      expect(parsed.first).to be_an_instance_of MiddlewareOne
    end
  end
end
