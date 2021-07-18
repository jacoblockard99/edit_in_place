# frozen_string_literal: true

module EditInPlace
  # {FieldType} is a class that represents a single type of field. A field is a single,
  # self-contained component that displays data in various "modes", typically either "viewing" or
  # "editing". Field types provide the templates for similar fields.
  #
  # @abstract
  # @author Jacob Lockard
  # @since 0.1.0
  class FieldType
    # Render the field, given the mode and an array of arguments passed by
    # the caller.
    #
    # While subclasses may override this method as appropriate, the default
    # implementation simply does two things:
    # 1. uses {#validate_mode!} to ensure that the mode is supported, and
    # 2. calls a +render_*+ method.
    # For example, if the mode were +:admin_editing+, then a +render_admin_editing+ method would
    # be called. Naturally, the +render_*+ methods need to be defined by the subclass.
    # @param mode [Symbol] the mode with which to render the field.
    # @param args [Array<Object>] the arguments passed by the field creator.
    # @return the rendered result.
    def render(mode, *args)
      validate_mode!(mode)
      send("render_#{mode}", mode, *args)
    end

    # Gets the modes that are supported by this field type, +:viewing+ and +:editing+ by default.
    # @return [Array<Symbol>] the modes supported by this field type.
    # @note Subclasses should override this method as appropriate.
    def supported_modes
      %i[viewing editing]
    end

    # @!method dup
    #   Should create a deep copy of this {FieldType} that can be safely modified.
    #   @return [FieldType] a deep copy of this field type.
    #   @note This method should be overriden as necessary by subclasses to duplicate any added
    #     data.

    protected

    # Ensures that the given mode is supported by this field type.
    # @param mode [Symbol] the mode to validate.
    # @return [void]
    def validate_mode!(mode)
      raise UnsupportedModeError, mode unless supported_modes.include? mode
    end
  end
end
