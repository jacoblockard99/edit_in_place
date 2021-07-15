# frozen_string_literal: true

module EditInPlace
  # The class that provides the actual functionality to build and render editable content. This
  # class will usually be instantiated in a controller and passed somehow to a view. The view can
  # then use its methods to generate content.
  #
  # This class can be extended by utilizing {ExtendedBuilder} to safely add additional
  # functionality. This can be particularly helpful for edit_in_place extensions that would like
  # to add other content generation methods without requiring the user to yield another builder
  # to the view.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class Builder
    # @return [Configuration] the configuration for this {Builder}.
    # @note This configuration is initially derived from the global configuration defined in
    #   {EditInPlace.config}.
    attr_accessor :config

    # Creates a new instance of {Builder}.
    def initialize
      @config = EditInPlace.config.dup
    end

    # Creates a deep copy of this {Builder} that can be safely modified.
    # @return [Builder] a deep copy of this {Builder}.
    def dup
      b = Builder.new
      b.config = config.dup
      b
    end

    # Configures this {Builder} by yielding its configuration to the given block.
    # @yieldparam config [Configuration] the {Configuration} instance associated with this
    #   {Builder}.
    # @yieldreturn [void]
    # @return [void]
    # @see EditInPlace.configure
    def configure
      yield config if block_given?
    end

    # @overload field(type, options, *args)
    #   Renders a single field, given the field type, the field options, and a list of arguments
    #   to be passed to the field type renderer.
    #   @param type [FieldType, Symbol] The type of field to render, either an actual instance of
    #     {FieldType], or the symbol name of a registered field type.
    #   @param options [FieldOptions, Hash, #[]] The field options to be used when rendering the
    #     field. These options are defined in {FieldOptions}. Either an actual instance of
    #     {FieldOptions} or a hash are acceptable.
    #   @param args [Object] The arguments to be passed to the field renderer.
    #   @return [String] The rendered field, as HTML.
    # @overload field(type, *args)
    #   Renders a single field, given the field type and a list of arguments to be passed to the
    #   field type renderer. The default field options (as defined in {FieldOptions}) will be
    #   used.
    #   @param type [FieldType, Symbol] The type of field to render, either an actual instance of
    #     {FieldType], or the symbol name of a registered field type.
    #   @param args [Object] The arguments to be passed to the field renderer.
    #   @return [String] The rendered field, as HTML.
    def field(type, *args)
      inject_field_options!(args)
      args[0] = config.field_options.merge(args[0])

      definition = Middlegem::ArrayDefinition.new(config.defined_middlewares)
      stack = Middlegem::Stack.new(definition, middlewares: args[0].middlewares)
      args = stack.call(*args)

      type = evaluate_field_type(type)
      type.render(*args)
    end

    private

    # Ensures that the first argument in the given list of arguments is a valid, appropriate
    # {FieldOptions} instance for the list of arguments. In particular:
    # - When the first argument is already an instance of {FieldOptions}, the argument list
    #   is not touched.
    # - When the first argument is a hash, then it is converted to a
    #   {FieldOptions} instance.
    # - Otherwise, the default {FieldOptions} instance is prepended to the argument list.
    # @param args [Array] the raw arguments into which to inject the field options.
    # @return [void]
    def inject_field_options!(args)
      options = args.first

      return if options.is_a? FieldOptions

      if options.is_a? Hash
        args[0] = FieldOptions.new(options)
      else
        args.unshift(FieldOptions.new)
      end
    end

    # Gets an appropriate {FieldType} instance for the given raw field type argument. In
    # particular:
    # - When the input is already a FieldType instance, that instance is simply returned.
    # - When the input is a symbol, attempts to find a registered field type associated with it.
    # - Otherwise, raises an error.
    # @return [FieldType] an appropriate {FieldType} instance for the given input.
    def evaluate_field_type(type)
      case type
      when FieldType
        type
      when Symbol
        result = config.field_types.find(type)
        raise UnregisteredFieldTypeError, type if result.nil?

        result
      else
        raise InvalidFieldTypeError, type
      end
    end
  end
end
