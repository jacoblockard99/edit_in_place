# frozen_string_literal: true

module EditInPlace
  # Stores configuration for an edit_in_place {Builder}.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class Configuration
    # The default mode in which fields should be rendered if left unpspecified in the
    # configuration.
    DEFAULT_MODE = :viewing

    # @return [FieldTypeRegistrar] the {FieldTypeRegistrar} that stores the list of registered
    #   field types.
    attr_accessor :field_types

    # @return [FieldOptions] the default field options to use when rendering a field.
    attr_accessor :field_options

    # Creates a new, default instance of {Configuration}.
    def initialize
      @field_types = FieldTypeRegistrar.new
      @field_options = FieldOptions.new(mode: DEFAULT_MODE)
    end

    # Creates a deep copy of this {Configuration} that can be safely modified.
    # @return [Configuration] a deep copy of this configuration.
    def dup
      c = Configuration.new
      c.field_types = field_types.dup
      c.field_options = field_options.dup
      c
    end
  end
end
