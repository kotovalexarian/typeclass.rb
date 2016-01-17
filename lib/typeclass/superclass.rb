class Typeclass < Module
  ##
  # Superclass for typeclass constructor.
  #
  class Superclass
    attr_reader :typeclass, :args

    def initialize(typeclass, args)
      @typeclass = typeclass
      @args = args
    end

    ##
    # Typeclass extension for superclasses.
    #
    module TypeclassMixin
      def [](*args)
        fail TypeError unless args.all? { |arg| arg.is_a? Symbol }
        fail ArgumentError unless args.count == constraints.count

        Superclass.new self, args
      end
    end
  end
end
