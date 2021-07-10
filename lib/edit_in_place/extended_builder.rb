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
  # @author Jacob Lockard
  # @since 0.1.0
  class ExtendedBuilder
    # @return [Object] the base builder instance which this {ExtendedBuilder} extends. It should
    #   quack like a {Builder}.
    attr_reader :base

    delegate_missing_to :base

    # Creates a new {ExtendedBuilder} with the given base builder.
    # @param base [Object] The base builder to extend. It should quack like a {Builder}.
    def initialize(base)
      @base = base
    end
  end
end
