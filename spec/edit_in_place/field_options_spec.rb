# frozen_string_literal: true

require 'edit_in_place'
require 'support/test_middleware'

RSpec.describe EditInPlace::FieldOptions do
  let(:field_options) { described_class.new }

  describe '#initialize' do
    context 'when given options' do
      let(:field_options) do
        described_class.new(mode: :example, view: 'random object', middlewares: [:random])
      end

      it 'sets the mode' do
        expect(field_options.mode).to eq :example
      end

      it 'sets the middlewares' do
        expect(field_options.middlewares).to eq [:random]
      end
    end

    context 'when given a string mode' do
      let(:field_options) { described_class.new(mode: 'example') }

      it 'is converted to a symbol' do
        expect(field_options.mode).to eq :example
      end
    end

    context 'when given a nil mode' do
      let(:field_options) { described_class.new(mode: nil) }

      it 'sets the mode to nil' do
        expect(field_options.mode).to be_nil
      end
    end

    context 'when given no middlewares' do
      let(:field_options) { described_class.new }

      it 'sets the middleares to an empty array' do
        expect(field_options.middlewares).to eq []
      end
    end
  end

  describe '#mode=' do
    context 'when given a string mode' do
      it 'is converted to a symbol' do
        field_options.mode = 'example'
        expect(field_options.mode).to eq :example
      end
    end

    context 'when given nil' do
      it 'sets the mode to nil' do
        field_options.mode = nil
        expect(field_options.mode).to be_nil
      end
    end
  end

  describe '#dup' do
    let(:field_options) do
      described_class.new(
        mode: :random,
        view: 'random view object',
        middlewares: [:random, TestMiddleware.new, TestMiddleware]
      )
    end

    let(:dup) { field_options.dup }

    it 'returns a different instance' do
      expect(dup.object_id).not_to eq field_options.object_id
    end

    it 'copies the mode' do
      expect(dup.mode).to eq :random
    end

    it 'copies the middlewares' do
      expect(dup.middlewares.count).to eq 3
    end

    it 'duplicates the middlewares' do
      expect(dup.middlewares.object_id).not_to eq field_options.middlewares.object_id
    end

    it 'performs a deep duplication of the middlewares' do
      expect(dup.middlewares[1].object_id).not_to eq field_options.middlewares[1].object_id
    end

    it 'does not duplicate middleware classes' do
      expect(dup.middlewares[2].object_id).to eq field_options.middlewares[2].object_id
    end
  end

  describe '#merge!' do
    before { field_options.merge!(other) }

    context 'when both instances contain a mode' do
      let(:field_options) { described_class.new(mode: :old) }
      let(:other) { described_class.new(mode: :new) }

      it 'overwrites this instance' do
        expect(field_options.mode).to eq :new
      end
    end

    context 'when the other instance does not contain a mode' do
      let(:field_options) { described_class.new(mode: :old) }
      let(:other) { described_class.new }

      it 'keeps the old mode' do
        expect(field_options.mode).to eq :old
      end
    end

    context 'when both instances contain middlewares' do
      let(:middleware) { TestMiddleware.new }
      let(:field_options) { described_class.new(middlewares: [:one, :two, middleware]) }
      let(:other) { described_class.new(middlewares: %i[three four]) }

      it 'merges the middleware arrays' do
        expected = [:one, :two, middleware, :three, :four]
        expect(field_options.middlewares).to match_array expected
      end
    end
  end

  describe '#merge' do
    let(:field_options) do
      described_class.new(mode: :old, view: 'old view', middlewares: %i[one two])
    end
    let(:other) do
      described_class.new(mode: :new, view: 'new view', middlewares: %i[three four])
    end
    let(:merged) { field_options.merge(other) }

    it 'merges the mode' do
      expect(merged.mode).to eq :new
    end

    it 'merges the middlewares' do
      expect(merged.middlewares).to match_array %i[one two three four]
    end

    it 'returns a new instance' do
      expect(merged.object_id).not_to eq field_options.object_id
    end

    it 'does not change the original mode' do
      expect(field_options.mode).to eq :old
    end

    it 'does not change the original middlewares' do
      expect(field_options.middlewares).to eq %i[one two]
    end

    it 'does not change the other original middlewares' do
      expect(other.middlewares).to eq %i[three four]
    end
  end
end
