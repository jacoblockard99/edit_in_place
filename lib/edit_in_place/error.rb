# frozen_string_literal: true

module EditInPlace
  # {Error} is a subclass of {https://ruby-doc.org/core-2.5.0/StandardError.html StandardError}
  # from which all custom errors in edit_in_place are derived. One potential use for this class
  # is to rescue all custom errors produced by edit_in_place. For example:
  #
  #   begin
  #     # Do something risky with edit_in_place here...
  #   rescue EditInPlace::Error
  #     # Catch any edit_in_place-specific error here...
  #   end
  #
  # @see https://ruby-doc.org/core-2.0.0/Exception.html
  class Error < StandardError; end
end
