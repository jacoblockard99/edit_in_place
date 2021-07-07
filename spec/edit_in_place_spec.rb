require 'rails_helper'

RSpec.describe EditInPlace do
  before do
    # Reset the global configuration.
    EditInPlace.config = Configuration.new
  end

  describe '.config=' do
    before do
      c = Configuration.new
      c.field_options.mode = :editing
      EditInPlace.config = c
    end

    it 'sets the global configuration' do
      expect(EditInPlace.config.field_options.mode).to eq :editing
    end
  end

  describe '.configure' do
    it 'yields the configuration' do
      EditInPlace.configure do |c|
        expect(c).to eq EditInPlace.config
      end
    end

    it 'changes the configuration' do
      EditInPlace.configure do |c|
        c.field_options.view = 'random view'
      end
      expect(EditInPlace.config.field_options.view).to eq 'random view'
    end
  end
end
