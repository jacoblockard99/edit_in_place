# frozen_string_literal: true

module EditInPlace
  # A subcalss of {Registrar} that stores a list of {FieldType} instances registered with symbol
  # names.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class FieldTypeRegistrar < Registrar
    protected

    # Adds to the default `validate_registration!` implementation by ensuring that only
    # {FieldType} instances can be registered.
    # @param name [Symbol] the name to validate.
    # @param field_type [FieldType] the field type to validate.
    # @return [void]
    def validate_registration!(name, field_type)
      super
      raise InvalidFieldTypeError, field_type unless field_type.is_a? FieldType
    end
  end
end
