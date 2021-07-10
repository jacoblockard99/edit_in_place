# frozen_string_literal: true

module EditInPlace
  # An error that occurs when a field type is registered with an invalid name. This error usually
  # occurs when the name is not a symbol.
  class InvalidFieldTypeNameError < Error
    def initialize(name)
      super("The field type name '#{name}' is invalid!")
    end
  end
end
