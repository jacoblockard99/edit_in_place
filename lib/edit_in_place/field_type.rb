module EditInPlace
  # Represents a single type of field. A field is a single, self-contained component that
  # displays data in various "modes", typically either "viewing" or "editing". Field types
  # provide the templates for similar fields.
  #
  # @abstract
  # @author Jacob Lockard
  # @since 0.1.0
  class FieldType
    # Render the field given a {FieldOptions} instance and an array of arguments passed by
    # the caller.
    #
    # While subclasses may override this method as appropriate, the default
    # implementation simply does two things:
    # 1. uses {#validate_mode!} to ensure that the mode is supported, and
    # 2. calls a +render_*+ method.
    # For example, if the mode were +:admin_editing+, then a +render_admin_editing+ method would
    # be called. Naturally, the +render_*+ methods need to be defined by the subclass.
    # @param options [FieldOptions] options passed by the {Builder} instance that should
    #   be used to render the field.
    # @param args [Array<Object>] the arguments passed by the field creator.
    # @return [String] the rendered HTML.
    def render(options, *args)
      validate_mode!(options.mode)
      send("render_#{options.mode}", options, *args)
    end

    # Gets the modes that are supported by this field type, +:viewing+ and +:editing+ by default.
    # @return [Array<Symbol>] the modes supported by this field type.
    # @note Subclasses should override this method as appropriate.
    def supported_modes
      %i[viewing editing]
    end

    # Creates a deep copy of this {FieldType} that can be safely modified.
    # @return [FieldType] a deep copy of this field type.
    # @note This method should be overriden as necessary by subclasses to duplicate any added
    #   data.
    def dup
      super
    end

    protected

    # Ensures that the given mode is supported by this field type.
    # @param mode [Symbol] the mode to validate.
    # @return [void]
    def validate_mode!(mode)
      raise "The mode '#{mode}' is not supported by this field type!" unless supported_modes.include? mode
    end
  end
end
