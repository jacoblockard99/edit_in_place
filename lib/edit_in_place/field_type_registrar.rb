# frozen_string_literal: true

module EditInPlace
  # Stores a list of {FieldType} instances registered with symbol names.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class FieldTypeRegistrar
    # Creates a new instance of {FieldTypeRegistrar}.
    def initialize
      @field_types = {}
    end

    # Creates a deep copy of this {FieldTypeRegistrar} that can be safely modified.
    # @return [FieldTypeRegistrar] a deep copy of this registrar.
    def dup
      r = FieldTypeRegistrar.new
      r.register_all(field_types.deep_dup)
      r
    end

    # Registers the given {FieldType} with the given symbol name.
    # @param name [Symbol] The symbol name with which to associate the field type.
    # @param field_type [FieldType] The {FieldType} instance to register.
    # @return [void]
    # @see #register_all
    def register(name, field_type)
      validate_registration!(name, field_type)
      field_types[name] = field_type
    end

    # Registers all the symbol names and {FieldType} instances in the given hash. All elements of
    # the hash are passed through {#register}.
    # @param field_types [Hash<(Symbol, FieldType)>] The hash of field names and types to
    #   register.
    # @return [void]
    # @see #register
    def register_all(field_types)
      # The identical loops are necessary to prevent any middlewares from running if even one
      # fails the validation.

      # rubocop:disable Style/CombinableLoops
      field_types.each { |n, t| validate_registration!(n, t) }
      field_types.each { |n, t| register(n, t) }
      # rubocop:enable Style/CombinableLoops
    end

    # Attempts to find a {FieldType} associated with the given symbol name.
    # @param name [Symbol] The symbol name to search for.
    # @return [FieldType] if found.
    # @return [nil] if no field type was associated with the given name.
    def find(name)
      field_types[name]
    end

    # Gets a hash of all registered field types. Note that this hash is a clone of the actual,
    # internal one and can be safely modified.
    # @return [Hash<(Symbol, FieldType)>] The hash of registered names and field types.
    def all
      field_types.deep_dup
    end

    private

    # @return [Hash<(Symbol, FieldType)>] A hash of registered {FieldType} instances.
    attr_reader :field_types

    # Ensures that the given name--field type pair is valid, able to be registered in the
    # registrar. An error will raised if the registration fails validation. A registration is
    # valid if:
    # 1. the name is not already taken,
    # 2. the name is a symbol, and
    # 3. the field type is an instance of FieldType.
    # @param name [Symbol] the name to validate.
    # @param field_type [FieldType] the field type to validate.
    # @return [void]
    def validate_registration!(name, field_type)
      raise DuplicateFieldTypeRegistrationError, name if field_types.key?(name)
      raise InvalidFieldTypeNameError, name unless name.is_a? Symbol
      raise InvalidFieldTypeError, field_type unless field_type.is_a? FieldType
    end
  end
end
