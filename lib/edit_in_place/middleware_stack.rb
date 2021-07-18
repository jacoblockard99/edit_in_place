# frozen_string_literal: true

require 'middlegem'

module EditInPlace
  # {MiddlewareStack} is a class that is capable of applying the given array of middlewares to
  # a list of input arguments, given an array of defined middleware classes. It uses +middlegem+.
  #
  # @author Jacob Lockard
  # @since 0.2.0
  class MiddlewareStack
    # The array of defined middleware classes, in the order they should be run.
    # @return [Array] the array of defined middleware classes.
    attr_reader :defined_middlewares

    # The array of middlewares to be applied.
    # @return [Array] the middlewares.
    attr_reader :middlewares

    # The {MiddlewareRegistrar} used to look up middleware registrations.
    # @return [MiddlewareRegistrar] the middleware registrar.
    attr_reader :registrar

    # Creates a new instance of {MiddlewareStack} with the given defined middleware classes,
    # list of middlewares, and middleware registrar.
    # @param defined_middlewares [Array] the array of defined middleware classes.
    # @param middlewares [Array] the array of middlewares to apply.
    # @param registrar [MiddlewareRegistrar] the {MiddlewareRegistrar] used to look up middleware
    #   registrations.
    def initialize(defined_middlewares, middlewares, registrar)
      @defined_middlewares = defined_middlewares
      @registrar = registrar
      @middlewares = lookup_middlewares(middlewares)
    end

    # Applies the list of middlewares to the given input arguments.
    # @param args [Array] the argument list to transform.
    # @return [Array] the transformed argument list.
    def call(*args)
      definition = Middlegem::ArrayDefinition.new(defined_middlewares)
      stack = Middlegem::Stack.new(definition, middlewares: middlewares)
      stack.call(*args)
    end

    private

    # Iterates over the given middlewares and converts symbol names to their associated
    # registered middleware objects if possible.
    # @param middlewares [Array] the middlewares to iterate over.
    # @return [Array] the changed middlewares.
    def lookup_middlewares(middlewares)
      middlewares.map do |middleware|
        case middleware
        when Class
          middleware.new
        when Symbol
          lookup_middleware(middleware)
        else
          middleware
        end
      end
    end

    # Attempts to find a middleare registered with the given name in the middleare registrar. If
    # one could not be found, raises an appropriate error.
    # @param name [Symbol] the name to search for.
    # @return the found middleware.
    def lookup_middleware(name)
      result = registrar.find(name)
      raise UnregisteredMiddlewareError, name if result.nil?

      result
    end
  end
end
