module EditInPlace
  # Represents a single type of field. A field is a single, self-contained component that
  # displays data in various "modes", typically either "viewing" or "editing". Field types
  # provide the templates for similar fields.
  #
  # @abstract
  # @author Jacob Lockard
  # @since 0.1.0
  class FieldType
    # @!method render(options, args)
    #   Render the field given a {FieldOptions} instance and an array of arguments passed by
    #   the caller.
    #   @param options [FieldOptions] options passed by the {Builder} instance that should
    #     be used to render the field.
    #   @param args [Array<Object>] the arguments passed by the field creator.
    #   @return [String] the rendered HTML.
    #   @abstract All subclasses must implement #render.

    # Creates a deep copy of this {FieldType} that can be safely modified.
    # @return [FieldType] a deep copy of this field type.
    # @note This method should be overrided as necessary by sub-classes to duplicate any added
    #   data.
    def dup
      super
    end
  end
end
