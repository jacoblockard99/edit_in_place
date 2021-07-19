# frozen_string_literal: true

require 'edit_in_place/registrar'

module EditInPlace
  # {FieldTypeRegistrar} is a subcalss of {Registrar} that only allows {FieldType}
  # instances to be registered.
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
      unless field_type.is_a?(FieldType) || field_type.instance_of?(Class)
        raise InvalidFieldTypeError, field_type
      end
    end
  end
end
