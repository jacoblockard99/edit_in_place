# frozen_string_literal: true

module EditInPlace
  # An error that occurs when no registered field types exist for the field type name given.
  class UnregisteredFieldTypeError < Error
    # Creates a new instance of {UnregisteredFieldTypeError} with the given field type name that
    # caused the error.
    # @param field_type [Symbol] the field type that caused the error; used in the error message.
    def initialize(name)
      super("No field types are registered with the name '#{name}'")
    end
  end
end
