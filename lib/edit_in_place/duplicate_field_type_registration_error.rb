# frozen_string_literal: true

module EditInPlace
  # An error that occurs when a field type name that has already been registered is registered.
  class DuplicateFieldTypeRegistrationError < Error
    # Creates a new instance of {DuplicateFieldTypeRegistrationError} with the given field type
    # name that caused the error.
    # @param name [Symbol] the duplicate field type name that caused the error.
    def initialize(name)
      super("The field type name '#{name}' has already been registered!")
    end
  end
end
