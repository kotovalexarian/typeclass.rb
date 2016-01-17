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

    def implemented?(raw_params) # rubocop:disable Metrics/AbcSize
      params = args.map { |arg| raw_params[arg] }

      a = typeclass.send(:constraints).map do |k, _|
        { k => params.shift }
      end.inject(&:merge)

      typeclass.send(:instances).any? do |instance|
        a.all? { |k, v| v.ancestors.include? instance.params[k] }
      end
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

    def self.check!(superclasses)
      fail TypeError unless superclasses.all? do |superclass|
        superclass.is_a? Superclass
      end
    end
  end
end
