# frozen_string_literal: true

module EditInPlace
  # {Builder} is the class that provides the actual functionality to build and render editable
  # content. This class will usually be instantiated in a controller and passed somehow to a
  # view. The view can then use its methods to generate content. Note that when a {Builder} is
  # created, it's {Configuration} is copied from the global configuration.
  #
  # This class can be extended by utilizing {ExtendedBuilder} to safely add additional
  # functionality. This can be particularly helpful for edit_in_place extensions that would like
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
    # @param method_name [string] the name of the missing method being called.
    # @param args [Array] the arguments passed to the missing method.
    # @yield the block, if any, passed to the missing method.
    # @return the result of calling {#field} with the appropriate type if possible; the result of
    #   calling +super+ if not.
    # @since 0.2.0
    def method_missing(method_name, *args, &block)
      field_type = parse_field_method(method_name)
      field_type ? field(field_type, *args, &block) : super
    end

    # Overrides +respond_to_missing?+ to allow methods like +*_field+ to be respond to by
    # {Builder}.
    # @param method_name [string] the name of the missing method being checked.
    # @return true if the method name can be responded to by this {Builder}; false otherwise.
    # @since 0.2.0
    def respond_to_missing?(method_name, priv = false)
      parse_field_method(method_name) || super
    end

    # Creates a deep copy of this {Builder}, whose configuration can be safely modified.
    # @return [Builder] a deep copy of this {Builder}.
    def dup
      b = self.class.new
      b.config = config.dup
      b
    end

    # Configures this {Builder} by yielding its configuration to the given block. For example,
    #
    #   @builder = EditInPlace::Builder.new
    #   @builder.configure do |c|
    #     c.field_options.mode = :editing
    #     c.field_options.middlewares = [:one, :two]
    #   end
    #
    # Note that this method is simply a convenience method, and the above code is exactly
    # equivalent to the following:
    #
    #   @builder = EditInPlace::Builder.new
    #   @builder.config.field_options.mode = :editing
    #   @builder.config.field_options.middlewares = [:one, :two]
    # @yieldparam config [Configuration] the {Configuration} instance associated with this
    #   {Builder}.
    # @yieldreturn [void]
    # @return [void]
    # @see EditInPlace.configure
    def configure
      yield config if block_given?
    end

    # @overload field(type, options, *args)
    #   Renders a single field of the given type with the given field option and arguments
    #   to be passed to the field type renderer.
    #   @param type [FieldType, Symbol] the type of field to render, either an actual instance of
    #     {FieldType}, or the symbol name of a registered field type.
    #   @param options [FieldOptions, Hash] the field options to be used when rendering the
    #     field. These options are defined in {FieldOptions}. Either an actual instance of
    #     {FieldOptions} or a hash are acceptable.
    #   @param args [Array] the arguments to be passed to the field renderer.
    #   @return [String] the rendered field, as HTML.
    # @overload field(type, *args)
    #   Renders a single field of the given type with the given arguments to be passed to the
    #   field type renderer. The default field options (as defined in {FieldOptions}) will be
    #   used.
    #   @param type [FieldType, Symbol] the type of field to render, either an actual instance of
    #     {FieldType}, or the symbol name of a registered field type.
    #   @param args [Array] the arguments to be passed to the field renderer.
    #   @return [String] the rendered field, as HTML.
    def field(type, *args)
      inject_field_options!(args)
      args[0] = config.field_options.merge(args[0])

      stack = MiddlewareStack.new(config.defined_middlewares,
                                  args[0].middlewares,
                                  config.registered_middlewares)
      args = stack.call(*args)

      type = evaluate_field_type(type)
      type.render(*args)
    end

    # Yields a new, scoped {Builder} with the given field options. This method is helpful when
    # many fields require the same options. One use, for example, is to easily give field types
    # access to the current view context, like so:
    #
    #   <!-- some_view.html.erb -->
    #
    #   <%= @builder.scoped view: self do |b|
    #     <%= b.field(:example_type, 'random scoped field') %>
    #     <!-- ... -->
    #   <% end %>
    #
    # Now all fields generated using +b+ will have access to +self+ as the view context in
    # {FieldOptions#view}.
    # @yieldparam scoped_builder [Builder] the new, scoped {Builder} instance.
    # @yieldreturn [string] the output generated with the scoped builder.
    # @param field_options [FieldOptions, Hash] the field options that the scoped builder should
    #   have. Note that these options will be merged (using {FieldOptions#merge!}) with the
    #   current ones. Either an actual {FieldOptions} instance or a hash of options are
    #   acceptable.
    # @return [string] the output of the block.
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
    # @yieldreturn [string] the output.
    # @param middlewares [Array] the array of middlewares that the scoped builder should have
    #   merged into it.
    # @since 0.2.0
    def with_middlewares(*middlewares, &block)
      scoped(middlewares: middlewares, &block)
    end
    alias middleware_scope with_middlewares

    private

    def parse_field_method(method_name)
      method_name = method_name.to_s
      return nil unless method_name.end_with? '_field'

      field_type_name = method_name.delete_suffix('_field').to_sym
      config.field_types.find(field_type_name)
    end

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
