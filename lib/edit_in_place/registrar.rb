# frozen_string_literal: true

module EditInPlace
  # Stores a list of objects registered with symbol names.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class Registrar
    # Creates a new instance of {Registrar}.
    def initialize
      @registrations = {}
    end

    # Creates a deep copy of this {Registrar} that can be safely modified.
    # @return [Registrar] a deep copy of this registrar.
    def dup
      r = Registrar.new
      r.register_all(all)
      r
    end

    # Registers the given object with the given symbol name.
    # @param name [Symbol] The symbol name with which to associate the object.
    # @param object The object to register.
    # @return [void]
    # @see #register_all
    def register(name, object)
      validate_registration!(name, object)
      registrations[name] = object
    end

    # Registers al the symbol names and objects in the given hash. All elements of the hash are
    # passed through {#register}.
    # @param objects [Hash<(Symbol, Object)>] The has of names and objects to register.
    # @return [void]
    # @see #register
    def register_all(objects)
      # The identical loops are necessary to prevent anyything from being registered if even one
      # fails the validation.

      # rubocop:disable Style/CombinableLoops
      objects.each { |n, t| validate_registration!(n, t) }
      objects.each { |n, t| register(n, t) }
      # rubocop:enable Style/CombinableLoops
    end

    # Attempts to find an object associated with the given symbol name.
    # @parma name [Symbol] The symbol name to search for.
    # @return [Object] if found.
    # @return [nil] if no object was associated with the given name.
    def find(name)
      registrations[name]
    end

    # Gets a hash of all registrations. Ntoe that this hash is a deep clone of the actual,
    # internal one and can be safely modified.
    # @return [Hash<(Symbol, Object)>] The hash of registered names and objects.
    def all
      registrations.deep_dup
    end

    protected

    # @return [Hash<(Symbol, Object)>] A hash of registrations.
    attr_reader :registrations

    # Should ensure that the given registration is valid. By default a registration is valid is
    # its name is not already taken and is a symbol. Subclasses may override this method to add
    # validation rules.
    # @param name [Symbol] the name to validate.
    # @param object [Object] the object to validate.
    # @return [void]
    def validate_registration!(name, _object)
      if registrations.key?(name)
        raise DuplicateRegistrationError, <<~ERR
          The name '#{name}' has already been registered!
        ERR
      end

      unless name.is_a?(Symbol)
        raise InvalidRegistrationNameError, <<~ERR
          The name '#{name}' is not a valid symbol registration name!
        ERR
      end
    end
