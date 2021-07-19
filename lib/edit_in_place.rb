# frozen_string_literal: true

require 'edit_in_place/array_definition'
require 'edit_in_place/builder'
require 'edit_in_place/configuration'
require 'edit_in_place/extended_builder'
require 'edit_in_place/field_options'
require 'edit_in_place/field_type'
require 'edit_in_place/field_type_registrar'
require 'edit_in_place/middleware_registrar'
require 'edit_in_place/middleware_wrapper'
require 'edit_in_place/registrar'
require 'edit_in_place/version'

require 'edit_in_place/error'
require 'edit_in_place/duplicate_registration_error'
require 'edit_in_place/invalid_field_type_error'
require 'edit_in_place/invalid_registration_name_error'
require 'edit_in_place/unregistered_field_type_error'
require 'edit_in_place/unregistered_middleware_error'
require 'edit_in_place/unsupported_mode_error'

# {EditInPlace} is a namespace that contains all the modules and classes of the edit_in_place
# Rails gemified plugin.
#
# @author Jacob Lockard
# @since 0.1.0
module EditInPlace
  @config = Configuration.new

  # Gets the `Configuration` instance that represents the global configuration for the
  # edit_in_place plugin. The global configuration will be applied to all created {Builder}
  # instances.
  # @return [Configuration] the global configuration.
  # @see Configuration
  def self.config
    @config
  end

  # Sets the `Configuration` instance that represents the global configuration for the
  # edit_in_place plugin. A convenient use for this method is to reset the global configuration
  # by setting it to +EditInPlace::Configuration.new+.
  # @param config [Configuration] the global configuration.
  # @return [void]
  # @see Configuration
  def self.config=(config)
    @config = config
  end

  # Configures the edit_in_place plugin by yielding the global configuration to the given block.
  # This is a convenient way to configure the plugin. For example:
  #
  #   EditInPlace.configure do |c|
  #     c.field_options.mode = :editing
  #     c.defined_middlewares = [SomeMiddleware, AnotherMiddleware]
  #   end
  # @yieldparam config [Configuration] the {Configuration} instance of the edit_in_place plugin.
  # @yieldreturn [void]
  # @return [void]
  # @see Configuration
  def self.configure
    yield config if block_given?
  end
end
