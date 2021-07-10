# frozen_string_literal: true

module EditInPlace
  # An error that occurs when an object that cannot be parsed into a {FieldType} is used as one.
  class InvalidFieldTypeError < Error
    # Creates a new instance of {InvalidFieldTypeError} with the given field type that
    # caused the error.
    # @param field_type [object] the field type that caused the error; used in the error message.
    def initialize(field_type)
      super("'#{field_type.inspect}' is not a valid field type!")
    end
  end
end
