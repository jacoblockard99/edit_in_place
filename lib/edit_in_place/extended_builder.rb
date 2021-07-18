# frozen_string_literal: true

module EditInPlace
  # A base class that allows one to easily and safely extend the {Builder} class with additional
  # functionality. Every {ExtendedBuilder} contains a base builder to which it delegates all
  # missing method calls. In this way, builder instances can be extended multiple times, like so:
  #   base = Builder.new({...})
  #   base.respond_to? :field # => true
  #
  #   hello_builder = HelloBuilder.new(base_builder, {...}) # a sub-class of ExtendedBuilder
  #   hello_builder.respond_to? :hello # => true
  #   hello_builder.respond_to? :field # => true
  #
  #   world_builder = WorldBuilder.new(hello_builder, {...}) # a sub-class of ExtendedBuilder
  #   world_builder.respond_to? :world # => true
  #   world_builder.respond_to? :hello # => true
  #   world_builder.respond_to? :field # => true
  #
  # A word of caution is in order, however! An {ExtendedBuilder} should *never*
  # override a method on the base builder. While this may seem like a convenient way to add new
  # methods to {Builder}, it can cause problems, since other methods further along in the chain
  # will not call the overriden one. {ExtendedBuilder} is intended only for adding new methods,
  # not mdifying existing ones.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class ExtendedBuilder
    # @return [Object] the base builder instance which this {ExtendedBuilder} extends. It should
    #   quack like a {Builder}.
    attr_reader :base

    # Creates a new {ExtendedBuilder} with the given base builder.
    # @param base [Object] the base builder to extend. It should quack like a {Builder}.
    def initialize(base)
      @base = base
    end

    # Overrides +method_missing+ to allow the use of methods defined on the base builder.
    # @param method_name [String] the name of the missing method.
    # @param args [Array] the arguments given to the missing method.
    # @yield the block passed to the missing method.
    # @return the result of calling the method on the base builder, if it was defined, or the
    #   result of calling +super+ if not.
    def method_missing(method_name, *args, &block)
      base.respond_to?(method_name) ? base.send(method_name, *args, &block) : super
    end

    # Overrides +respond_to_missing?+ to respond to methods defined on the base builder.
    # @param method_name [String] the name of the missing method.
    # @return [Boolean] whether this {ExtendedBuilder} can respond to the given method name.
    def respond_to_missing?(method_name, priv = false)
      base.respond_to?(method_name) || super
    end
  end
end
