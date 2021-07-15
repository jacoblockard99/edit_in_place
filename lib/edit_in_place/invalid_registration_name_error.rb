# frozen_string_literal: true

module EditInPlace
  # An error that occurs when an object is registered with an invalid name. This error usually
  # occurs when the name is not a symbol.
  class InvalidRegistrationNameError < Error; end
end
