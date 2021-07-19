# frozen_string_literal: true

module EditInPlace
  # {MiddlewareParser} is a class that is capable of converting an array of middlewares to
  # middleware objects. For example:
  #
  #   registrar = FieldTypeRegistrar.new
  #   registrar.register :capitalize, CapitalizeMiddleware
  #   parser = MiddlewareParser(registrar)
  #
  #   middlewares = [:capitalize, LowercaseMiddleware, TitleizeMiddleware.new]
  #   parser.parse(middlewares)
  #   # => [#<CapitalizeMiddleware:...>, #<LowercaseMiddleware:...>, #<TitelizeMiddleware:...>]
  #
  # Notice how the symbol and class became middleware instances.
  #
  # @author Jacob Lockard
  # @since 0.2.0
  class MiddlewareParser
    # The {MiddlewareRegistrar} used to look up middleware registrations.
    # @return [MiddlewareRegistrar] the middleware registrar.
    attr_reader :registrar

    # Creates a new instance of {MiddlewareParser} with the given middleware registrar.
    # @param registrar [MiddlewareRegistrar] the middleware registrar used to look up middleware
    #   registrations.
    def initialize(registrar)
      @registrar = registrar
    end

    # Converts all the middlewares in the given array into middleware instances. In other words,
    # looks up all middleware names and instantiates middleware classes. The transformed array is
    # returned.
    # @param middlewares [Array] the array of middlewares to "parse".
    # @return [Array] the "parsed" array of middlewares.
    def parse(middlewares)
      middlewares.map do |m|
        m = lookup_middleware(m) if m.is_a? Symbol
        m.instance_of?(Class) ? m.new : m
      end
    end

    private

    # Attempts to find a middleware registered with the given name in the middleare registrar. If
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
