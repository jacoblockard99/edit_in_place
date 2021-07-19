# frozen_string_literal: true

require 'middlegem'

module EditInPlace
  # {ArrayDefinition} is a subclass of +Middlegem::ArrayDefinition+ that works properly with
  # {MiddlewareWrapper} instances.
  #
  # @author Jacob Lockard
  # @since 0.2.0
  class ArrayDefinition < Middlegem::ArrayDefinition
    protected

    # Overrides +matches_class?+ to use the base middleware's class if the middleware is a
    # {MiddlewareWrapper}.
    # @param middleware [Object] the middleware to check.
    # @param klass [Class] the class against which the middleware should be checked.
    # @return [Boolean] whether the given middleware has the given class.
    def matches_class?(middleware, klass)
      middleware.is_a?(MiddlewareWrapper) ? middleware.base.instance_of?(klass) : super
    end
  end
end
