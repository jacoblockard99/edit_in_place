# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EditInPlace do
  before do
    # Reset the global configuration.
    described_class.config = EditInPlace::Configuration.new
  end

  describe '.config=' do
    it 'sets the global configuration' do
      c = EditInPlace::Configuration.new
      c.field_options.mode = :editing
      described_class.config = c

      expect(described_class.config.field_options.mode).to eq :editing
    end
  end

  describe '.configure' do
    it 'yields the configuration' do
      described_class.configure do |c|
        expect(c).to eq described_class.config
      end
    end

    it 'changes the configuration' do
      described_class.configure do |c|
        c.field_options.middlewares = [:random]
      end
      expect(described_class.config.field_options.middlewares).to eq [:random]
    end
  end
end
