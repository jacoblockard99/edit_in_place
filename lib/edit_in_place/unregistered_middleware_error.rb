# frozen_string_literal: true

module EditInPlace
  # An error that occurs when no registered middlewares exist for the middleare name given.
  class UnregisteredMiddlewareError < Error
    # Creates a new instance of {UnregisteredMiddlewareError} with the given middleware name that
    # caused the error.
    # @param name [Symbol] the middleware that caused the error; used in the error message.
    def initialize(name)
      super("No middlewares are registered with the name '#{name}'")
    end
  end
end
