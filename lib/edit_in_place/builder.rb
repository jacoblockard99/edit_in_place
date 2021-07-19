# frozen_string_literal: true

module EditInPlace
  # {Builder} is the class that provides the actual functionality to build and render editable
  # content. If used in a Rails setting, this class will usually be instantiated in a controller
  # and passed somehow to a view. The view can then use its methods to generate content. Note
  # that when a {Builder} is created, its {Configuration} is copied from the global
  # configuration.
  #
  # This class can be extended by utilizing {ExtendedBuilder} to safely add additional
  # functionality. This can be particularly helpful for edit_in_place extensions that wish
  # to add other content generation methods without requiring the user to yield another builder
  # to the view.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class Builder
    # The {Configuration} instance that stores the options for this {Builder}.
    # @return [Configuration] the configuration for this {Builder}.
    # @note This configuration is initially derived from the global configuration defined in
    #   {EditInPlace.config}.
    attr_accessor :config

    # Creates a new instance of {Builder}.
    def initialize
      @config = EditInPlace.config.dup
    end

    # Overrides +method_missing+ to allow methods like +*_field+ to be called for registered
    # fields. For example, if a +:text+ field type has been registered, then calling
    # +Builder#text_field(...)+ is equivalent to calling +Builder#field(:text, ...)+.
    # @param method_name [Symbol, String] the name of the missing method being called.
    # @param args [Array] the arguments passed to the missing method.
    # @yield the block, if any, passed to the missing method.
    # @return the result of calling {#field} with the appropriate type if possible; the result of
    #   calling +super+ if not.
    # @since 0.2.0
    def method_missing(method_name, *args, &block)
      field_type = parse_field_method(method_name)
      field_type ? field(field_type, *args, &block) : super
    end

    # Overrides +respond_to_missing?+ to allow methods like +*_field+ to be responded to by
    # {Builder}.
    # @param method_name [Symbol, String] the name of the missing method being checked.
    # @return [Boolean] +true+ if this {Builder} can respond to the given method name; +false+
    #   otherwise.
    # @see #method_missing
    # @since 0.2.0
    def respond_to_missing?(method_name, inlude_private = false)
      parse_field_method(method_name) || super
    end

    # Creates a deep copy of this {Builder} whose configuration can be safely modified.
    # @return [Builder] a deep copy of this {Builder}.
    def dup
      b = self.class.new
      b.config = config.dup
      b
    end

    # Configures this {Builder} by yielding its configuration to the given block. For example:
    #
    #   @builder = EditInPlace::Builder.new
    #   @builder.configure do |c|
    #     c.field_options.mode = :editing
    #     c.field_options.middlewares = [:one, :two]
    #   end
    #
    # Note that this method is simply a convenience method and that the above code is exactly
    # equivalent to the following:
    #
    #   @builder = EditInPlace::Builder.new
    #   @builder.config.field_options.mode = :editing
    #   @builder.config.field_options.middlewares = [:one, :two]
    #
    # @yieldparam config [Configuration] the {Configuration} instance associated with this
    #   {Builder}.
    # @yieldreturn [void]
    # @return [void]
    def configure
      yield config if block_given?
    end

    # Renders a single "field", that is, a single piece of editable content defined by a field
    # type. Field options may or may not be provided and will be automatically injected if not.
    # The input given to this method will be transformed by any middlewares added from various
    # sources.
    # @overload field(type, options, *args)
    #   Renders a single field of the given type with the given field options and input.
    #   @param type [FieldType, Class, Symbol] the type of field to render, either an actual
    #     instance of {FieldType}, a field type class that can be instantiated with no arguments,
    #     or the symbol name of a registered field type.
    #   @param options [FieldOptions, Hash] the field options to be used when rendering the
    #     field. These options are as defined in {FieldOptions}. Either an actual instance of
    #     {FieldOptions} or a hash are acceptable.
    #   @param args [Array] the input arguments to be passed to `FieldType#render`.
    #   @return the rendered field.
    # @overload field(type, *args)
    #   Renders a single field of the given type with the default field options and the given
    #   input.
    #   @param type [FieldType, Class, Symbol] the type of field to render, either an actual
    #     instance of {FieldType}, a field type class that can be instantiated with no arguments,
    #     or the symbol name of a registered field type.
    #   @param args [Array] the input arguments to be passed to `FieldType#render`.
    #   @return the rendered field.
    def field(type, *args)
      options = config.field_options.merge(get_field_options!(args))
      args.unshift(options.mode)

      args = apply_middlewares(options.middlewares, *args)

      type = evaluate_field_type(type)
      type.render(*args)
    end

    # Yields a new, scoped {Builder} with the given field options. This method is helpful when
    # many fields require the same options.
    # @yieldparam scoped_builder [Builder] the new, scoped {Builder} instance.
    # @yieldreturn the output.
    # @param field_options [FieldOptions, Hash] the field options that the scoped builder should
    #   have. Note that these options will be merged (using {FieldOptions#merge!}) with the
    #   current ones. Either an actual {FieldOptions} instance or a hash of options are
    #   acceptable.
    # @return the output of the block.
    def scoped(field_options = {})
      field_options = FieldOptions.new(field_options) unless field_options.is_a? FieldOptions

      scoped_builder = dup
      scoped_builder.config.field_options.merge!(field_options)

      yield scoped_builder
    end
    # @since 0.2.0
    alias scope scoped

    # Yields a new, scoped {Builder} with the given middlewares merged into the current ones.
    # Note that this method is for convenience only and is exactly equivalent to calling
    # +scoped(middlewares: ...)+.
    # @yieldparam scoped_builder [Builder] the new, scoped {Builder} instance.
    # @yieldreturn the output.
    # @param middlewares [Array] the array of middlewares that the scoped builder should have
    #   merged into it.
    # @return the output of the block.
    # @since 0.2.0
    def with_middlewares(*middlewares, &block)
      scoped(middlewares: middlewares, &block)
    end
    alias middleware_scope with_middlewares

    private

    # Attempts to get a field type from the given '*_field' method name.
    # @param method_name [Symbol, String] the name of the method to parse.
    # @return [FieldType, nil] the field type if one could be found; +nil+ if not.
    def parse_field_method(method_name)
      method_name = method_name.to_s
      return nil unless method_name.end_with? '_field'

      field_type_name = method_name.delete_suffix('_field').to_sym
      config.field_types.find(field_type_name)
    end

    # Gets an appropriate {FieldOptions} instance for the given list of field arguments and
    # removes any present field options from the argument list.
    # @param args [Array] the raw arguments from which to get the field options.
    # @return [FieldOptions] the retrieved field options.
    # @since 0.2.0
    def get_field_options!(args)
      case args.first
      when FieldOptions
        args.shift
      when Hash
        FieldOptions.new(args.shift)
      else
        FieldOptions.new
      end
    end

    # Gets an appropriate {FieldType} instance for the given raw field type argument. In
    # particular:
    # - When the input is a symbol, attempts to find a registered field type associated with it.
    # - When the input is a class, instatiates it.
    # - When the input is already a FieldType instance, that instance is simply returned.
    # - Otherwise, raises an error.
    # @param type [Symbol, Class, FieldType] the raw field type argument to evaluate.
    # @return [FieldType] an appropriate {FieldType} instance for the given input.
    def evaluate_field_type(type)
      case type
      when Symbol
        evaluate_field_type(lookup_field_type(type))
      when Class
        evaluate_field_type(type.new)
      when FieldType
        type
      else
        raise InvalidFieldTypeError, type
      end
    end

    # Attempts to find a field type registered with the given name in the field type registrar.
    # If one could not be found, raises an appropriate error.
    # @param name [Symbol] the name to search for.
    # @return the found field type.
    # @since 0.2.0
    def lookup_field_type(name)
      result = config.field_types.find(name)
      raise UnregisteredFieldTypeError, name if result.nil?

      result
    end

    # Applies the given array of middlewares to the given input arguments and returns the result.
    # @param middlewares [Array] the array of middlewares to apply.
    # @param args [Array] the array of input arguments.
    # @return [Array] the resulting argument list.
    # @since 0.2.0
    def apply_middlewares(middlewares, *args)
      definition = ArrayDefinition.new(config.defined_middlewares)
      stack = Middlegem::Stack.new(definition, middlewares: wrap_middlewares(middlewares))

      stack.call(*args)
    end

    # Converts each of the given middleware instances into a {MiddlewareWrapper} and returns the
    # result.
    # @param middlewares [Array] the middlewares to wrap.
    # @return [Array] the wrapped middlewares.
    # @since 0.2.0
    def wrap_middlewares(middlewares)
      middlewares.map { |m| MiddlewareWrapper.new(m, config.registered_middlewares) }
    end
  end
end
