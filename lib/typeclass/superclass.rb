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
  end
end
