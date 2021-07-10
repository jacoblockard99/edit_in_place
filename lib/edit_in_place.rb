# frozen_string_literal: true
require 'edit_in_place/version'
require 'edit_in_place/railtie'
require 'edit_in_place/builder'
require 'edit_in_place/configuration'
require 'edit_in_place/extended_builder'
require 'edit_in_place/field_options'
require 'edit_in_place/field_type'
require 'edit_in_place/field_type_registrar'

# Namespace for the 'edit_in_place' Rails gemified plugin.
#
# @author Jacob Lockard
# @since 0.1.0
module EditInPlace
  @@config = Configuration.new

  # Gets the global configuration for the edit_in_place plugin.
  # @return [Configuration] the global configuration.
  def self.config
    @@config
  end

  # Sets the global configuration for the edit_in_place plugin.
  # @param config [Configuration] The global configuration.
  # @return [void]
  def self.config=(config)
    @@config = config
  end

  # Configures the edit_in_place plugin by yielding the global configuration to the given block.
  # @yieldparam config [Configuration] The {Configuration} instance of the edit_in_place plugin.
  # @yieldreturn [void]
  # @return [void]
  def self.configure
    yield config if block_given?
  end
end
