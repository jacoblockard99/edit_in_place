# frozen_string_literal: true

module EditInPlace
  # {MiddlewareRegistrar} is a subclass of {Registrar} that only allows middleware objects (as
  # defined by +Middlegem::Middleware.valid?+) to be registered.
  #
  # @author Jacob Lockard
  # @since 0.2.0
  class MiddlewareRegistrar < Registrar
    protected

    # Adds to the default +validate_registration!+ implementation by ensuring that only
    # middleware objects (as defined by +Middlegem::Middleware.valid?+) can be registered.
    def validate_registration!(name, middleware)
      super
      raise Middlegem::InvalidMiddlewareError unless Middlegem::Middleware.valid?(middleware)
    end
  end
end
