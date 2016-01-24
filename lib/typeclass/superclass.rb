class Typeclass < Module
  ##
  # Superclass for typeclass constructor.
  #
  class Superclass
    # @!attribute [r] typeclass
    # @return [Typeclass] Type class.
    # @api private
    attr_reader :typeclass

    # @!attribute [r] args
    # @return [Array<Symbol>] Args.
    # @api private
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
    # @api private
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
      # @api private
      def superclasses
        @superclasses ||= []
      end

      # Create superclass for typeclass constructor.
      #
      # @param args [Array<Symbol>] Names of type variables.
      #
      # @see Typeclass::Superclass#initialize
      #
      def [](*args)
        Superclass.new self, args
      end

      # Inherit from superclass
      #
      # @param superclass [Typeclass::Superclass] Which sperclass inherit from.
      # @return [void]
      #
      # @raise [TypeError, ArgumentError]
      #
      # @note
      #   Exceptions raised by this method should stay unhandled.
      #
      def include(superclass)
        fail TypeError unless superclass.is_a? Superclass
        fail ArgumentError unless superclass.args.all? do |arg|
          constraints.key? arg
        end

        superclasses << superclass

        inherit superclass
      end

      # Recursively include superclass' methods in the typeclass.
      #
      # @param superclass [Typeclass::Superclass] Which typeclass to include.
      # @return [void]
      #
      # @api private
      #
      def inherit(superclass)
        superclass.typeclass.functions.each(&method(:defun))
        superclass.typeclass.superclasses.each(&method(:inherit))
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
  end
end
