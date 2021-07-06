module EditInPlace
  # A class that stores the options and context required to render a field.
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

    # The view context to be used when rendering the field. This view context can be derived in
    # a number of ways, most commonly by creating a new instance of +ActionView::Base+.
    # @return the view context to be used when rendering the field.
    attr_accessor :view

    # @overload initialize(options)
    #   Creates a new instance of {FieldOptions} with the given options.
    #   @param options [Hash, #[]] A hash containing the given field options.
    # @overload initialize
    #   Creates a new instance of {FieldOptions} with the default options.
    def initialize(options = {})
      self.mode = options[:mode]
      self.view = options[:view]
    end

    def mode=(mode)
      @mode = mode.nil? ? nil : mode.to_sym
    end
  end
end
