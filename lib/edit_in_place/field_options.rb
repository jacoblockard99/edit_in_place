# frozen_string_literal: true

module EditInPlace
  # {FieldOptions} is a class that stores the options and context required to render a field.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class FieldOptions
    # @overload mode
    #   Gets the "mode" with which the field should be rendered. For example, a text field may
    #   render an +<input type="text" ...>+ element when in an "editing" mode, but render simple
    #   text in a "viewing" mode.
    #   @return [Symbol] the mode in which the field should be rendered.
    # @overload mode=
    #   Sets the new mode.
    #   @param mode [String, Symbol, nil] the new mode.
    #   @note All strings will be converted to symbols.
    #   @return [void]
    attr_reader :mode

    # An array of middleware instances that should be applied to the field's input.
    # @return the array of middlewares.
    attr_accessor :middlewares

    # @overload initialize(options)
    #   Creates a new instance of {FieldOptions} with the given options.
    #   @param options [Hash, #[]] a hash containing the given field options.
    #   @option options [Symbol] :mode the {#mode} in which fields should be rendered.
    #   @option options [Array] :middlewares the {#middlewares} for the field.
    # @overload initialize
    #   Creates a new instance of {FieldOptions} with the default options.
    def initialize(options = {})
      self.mode = options[:mode]
      self.middlewares = options[:middlewares] || []
    end

    # Documentation for this method resides in the attribute declaration.
    def mode=(mode)
      @mode = mode.nil? ? nil : mode.to_sym
    end

    # Creates a deep copy of this {FieldOptions} instance that can be safely modified.
    # @return [FieldOptions] a deep copy of this {FieldOptions} instance.
    def dup
      f = self.class.new
      f.mode = mode
      f.middlewares = middlewares.map { |m| m.instance_of?(Class) ? m : m.dup }
      f
    end

    # Merges the given {FieldOptions} instance into this one. Modes and view contexts from the
    # other instance will overwrite those in this instance if present. The other instance is
    # duplicated before being merged, so it can be safely modified after the fact. All
    # middleware arrays will be merged.
    # @param other [FieldOptions] the other field options to merge into this one.
    # @return [void]
    def merge!(other)
      other = other.dup

      self.mode = other.mode unless other.mode.nil?
      self.middlewares += other.middlewares
    end

    # Creates a _new_ {FieldOptions} instance that is the result of merging the given
    # {FieldOptions} instance into this one. Neither instance is modified, and both are
    # duplicated, meaning that they can be safely modified after the fact. Merging occurs exactly
    # as with {#merge!}.
    # @param other [FieldOptions] the other field options to merge into this one.
    # @return [FieldOptions] the result of merging the two instances.
    def merge(other)
      new = dup
      new.merge!(other)
      new
    end
  end
end
