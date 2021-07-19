# frozen_string_literal: true

RSpec.describe EditInPlace::MiddlewareWrapper do
  let(:registrar) { EditInPlace::MiddlewareRegistrar.new }
  let(:wrapper) { described_class.new(base, registrar) }

  describe '#call' do
    context 'with a valid middleware object' do
      let(:base) { MiddlewareOne.new }

      it 'transforms the input correctly' do
        expect(wrapper.call(:viewing, 'input')).to eq [:viewing, 'input*ONE*']
      end
    end

    context 'with a valid registered middleware name' do
      before { registrar.register(:lowercase, MiddlewareOne.new) }

      let(:base) { :lowercase }

      it 'transforms the input correctly' do
        expect(wrapper.call(:editing, 'hello')).to eq [:editing, 'hello*ONE*']
      end
    end

    context 'with a middleware class' do
      let(:base) { MiddlewareOne }

      it 'transforms the input correctly' do
        expect(wrapper.call(:random, 'input')).to eq [:random, 'input*ONE*']
      end
    end

    context 'with a registered middleware class' do
      before { registrar.register :one, MiddlewareOne }

      let(:base) { :one }

      it 'transforms the input correctly' do
        expect(wrapper.call(:mode, 'random')).to eq [:mode, 'random*ONE*']
      end
    end
  end
end
