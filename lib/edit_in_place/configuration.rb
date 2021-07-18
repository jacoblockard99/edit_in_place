# frozen_string_literal: true

module EditInPlace
  # {Configuration} is a class that is capable of storing configuration for an edit_in_place
  # {Builder}. Essentially all the options provided by edit_in_place reside in this class for
  # easy reuse. This class is currently used in two locations---the global configuration in
  # {EditInPlace.config} and the builder-specific configuration in {Builder#config}.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class Configuration
    # The default mode in which fields should be rendered if left unpspecified in the
    # configuration.
    DEFAULT_MODE = :viewing

    # The {FieldTypeRegistrar} used to store the list of registered field types.
    # @return [FieldTypeRegistrar] the {FieldTypeRegistrar} that stores the list of registered
    #   field types.
    attr_accessor :field_types

    # The default {FieldOptions} instance to use when a builder renders a field. Note that this
    # instance will be merged with the one passed directly to {Builder#field}.
    # @return [FieldOptions] the default field options to use when rendering a field.
    attr_accessor :field_options

    # An array containing all the middleware classes permitted, in the order they should be run.
    # @return [Array] the array of defined middlewares.
    attr_accessor :defined_middlewares

    # The {MiddlewareRegistrar} used to store the list of registered middlewares.
    # @return [MiddlewareRegistrar] the {MiddlewareRegistrar} that stores the list of registered
    #   middlewares.
    attr_accessor :registered_middlewares

    # Creates a new, default instance of {Configuration}.
    def initialize
      @field_types = FieldTypeRegistrar.new
      @field_options = FieldOptions.new(mode: DEFAULT_MODE)
      @defined_middlewares = []
      @registered_middlewares = MiddlewareRegistrar.new
    end

    # Creates a deep copy of this {Configuration} that can be safely modified.
    # @return [Configuration] a deep copy of this configuration.
    def dup
      c = Configuration.new
      c.field_types = field_types.dup
      c.field_options = field_options.dup
      # Note that this is purposely NOT a deep copy---it doesn't make sense to duplicate classes.
      c.defined_middlewares = defined_middlewares.dup
      c.registered_middlewares = registered_middlewares.dup
      c
    end
  end
end
