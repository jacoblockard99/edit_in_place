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

    # Creates a deep copy of this {Builder}, whose configuration can be safely modified.
    # @return [Builder] a deep copy of this {Builder}.
    def dup
      b = Builder.new
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
