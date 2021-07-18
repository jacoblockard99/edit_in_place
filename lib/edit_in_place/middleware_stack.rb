# frozen_string_literal: true

require 'middlegem'

module EditInPlace
  # {MiddlewareStack} is a class that is capable of applying the given array of middlewares to
  # a list of input arguments, given an array of defined middlewares. It uses +middlegem+.
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

    # Creates a new instance of {MiddlewareStack} with the given defined middleware classes and
    # list of middlewares.
    # @param defined_middlewares [Array] the array of defined middleware classes.
    # @param middlewares [Array] the array of middlewares to apply.
    def initialize(defined_middlewares, middlewares)
      @defined_middlewares = defined_middlewares
      @middlewares = middlewares
    end

    # Applies the list of middlewares to the given input arguments.
    # @input [Array] the argument list to transform.
    # @return [Array] the transformed argument list.
    def call(*args)
      definition = Middlegem::ArrayDefinition.new(defined_middlewares)
      stack = Middlegem::Stack.new(definition, middlewares: middlewares)
      stack.call(*args)
    end
  end
end
