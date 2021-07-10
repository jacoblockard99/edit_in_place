# frozen_string_literal: true

module EditInPlace
  # An error that occurs when a field is rendered with a mode that is does not support.
  class UnsupportedModeError < Error
    # Creates a new instance of {UnsupportedModeError} with the given mode that
    # caused the error.
    # @param field_type [Symbol] the mode that caused the error.
    def initialize(mode)
      super("The mode '#{mode}' is not supported by this field type!")
    end
  end
end
