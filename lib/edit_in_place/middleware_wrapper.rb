# frozen_string_literal: true

require 'middlegem'

module EditInPlace
  # {MiddlewareWrapper} is a class that provides a consistent wrapper for a middleware, which
  # currently can be one of the following:
  #   1. an actual middleware object (i.e. an object that responds to +#call+),
  #   2. a symbol name corresponding to a registered middleware, or
  #   3. a parameterless middleware class that should be instantiated.
  # {MiddlewareWrapper}, which is itself a +Middlegem::Middleware+ does all the necessary
  # conversions, providing a simple {#call} method.
  #
  # @author Jacob Lockard
  # @since 0.2.0
  class MiddlewareWrapper < Middlegem::Middleware
    # The base middleware, which should be a middleware object, a middleware class, or a
    # middleware name.
    # @return the base middleware.
    attr_reader :base

    # Creates a new instance of {MiddlewareWrapper} with the given middleware and registrar.
    # @param base the middleware to wrap.
    # @param registrar [MiddlewareRegistrar] the middleware registrar in which to search for
    #   registered middlewares.
    def initialize(base, registrar)
      base = lookup_middleware(base, registrar) if base.is_a? Symbol
      base = base.new if base.instance_of? Class

      @base = base

      super()
    end

    # Executes this {MiddlewareWrapper} with the given input by delegating appropriately to the
    # base middleware.
    # @param args [Array] the input arguments.
    # @return [Array] the transformed output.
    def call(*args)
      base.call(*args)
    end

    # Overrides +to_s+ to use the base middleware's string representation. This ensures that
    # error messages are displayed properly.
    # @return [String] the string representation of the base middleware.
    def to_s
      base.to_s
    end

    private

    # Attempts to find a middleware registered with the given name in the middleware registrar.
    # If one could not be found, raises an appropriate error.
    # @param name [Symbol] the name to search for.
    # @return the found middleware.
    def lookup_middleware(name, registrar)
      result = registrar.find(name)
      raise UnregisteredMiddlewareError, name if result.nil?

      result
    end
  end
end
