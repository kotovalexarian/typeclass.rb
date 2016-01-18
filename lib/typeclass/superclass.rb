class Typeclass < Module
  ##
  # Superclass for typeclass constructor.
  #
  class Superclass
    # @!attribute [r] typeclass
    # @return [Typeclass] Type class.
    attr_reader :typeclass

    # @!attribute [r] args
    # @return [Array<Symbol>] Args.
    attr_reader :args

    # Create superclass for typeclass constructor.
    #
    # @param typeclass [Typeclass] Typeclass to be a superclass.
    # @param args [Array<Symbol>] Names of type variables.
    #
    def initialize(typeclass, args)
      fail TypeError unless args.all? { |arg| arg.is_a? Symbol }
      fail ArgumentError unless args.count == typeclass.constraints.count

      @typeclass = typeclass
      @args = args
    end

    # Check if typeclass is implemented for given type parameters.
    #
    # @param raw_params [Hash] Type parameters.
    # @return [Boolean] Is typeclass implemented.
    #
    def implemented?(raw_params) # rubocop:disable Metrics/AbcSize
      params = args.map { |arg| raw_params[arg] }

      a = typeclass.constraints.map do |k, _|
        { k => params.shift }
      end.inject(&:merge)

      typeclass.instances.any? do |instance|
        a.all? { |k, v| v.ancestors.include? instance.params[k] }
      end
    end

    ##
    # Typeclass extension for superclasses.
    #
    module TypeclassMixin
      # @!attribute [r] superclasses
      # @return [Array<Typeclass::Superclass>] Type class superclasses.
      attr_reader :superclasses

      # Create superclass for typeclass constructor.
      #
      # @param args [Array<Symbol>] Names of type variables.
      #
      # @see Typeclass::Superclass#initialize
      #
      def [](*args)
        Superclass.new self, args
      end

      # Recursively include superclass' methods in the typeclass.
      #
      # @param superclass [Typeclass::Superclass] Which typeclass to include.
      # @return [void]
      #
      # @api private
      #
      def inherit(superclass)
        typeclass = superclass.typeclass

        typeclass.singleton_methods.each do |method_name|
          p = typeclass.method method_name

          define_singleton_method method_name, &p
          define_method method_name, &p
        end

        typeclass.superclasses.each(&method(:inherit))
      end

      # Check if superclasses are implemented for typeclass instance's params.
      # Raise exceptions if not implemented.
      #
      # @param raw_params [Hash] Type parameters.
      # @return [void]
      #
      # @raise [NotImplementedError]
      #
      # @api private
      #
      def check_superclasses_implemented!(raw_params)
        fail NotImplementedError unless superclasses.all? do |superclass|
          superclass.implemented? raw_params
        end
      end
    end

    # Check if array items are superclasses.
    # Raise exception if not.
    #
    # @param superclasses [Array<Typeclass::Superclass>] Items to check.
    #
    # @raise [TypeError]
    #
    # @api private
    #
    def self.check!(superclasses)
      fail TypeError unless superclasses.all? do |superclass|
        superclass.is_a? Superclass
      end
    end

    # Check if superclass constraints uses only constraint type valiables.
    # Raise exceptions if undefined type variables is used.
    #
    # @param constraints [Hash] Type parameter constraints.
    # @param superclasses [Array<Typeclass::Superclass>] Array of superclasses.
    # @return [void]
    #
    # @raise [ArgumentError]
    #
    # @api private
    #
    def self.check_superclass_args!(constraints, superclasses)
      fail ArgumentError unless superclasses.all? do |superclass|
        superclass.args.all? { |arg| constraints.key? arg }
      end
    end
  end
end
