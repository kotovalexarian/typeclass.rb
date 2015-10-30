class Typeclass < Module
  class Instance
    ##
    # Named type parameters for type class instance
    #
    class Params
      def initialize(data)
        @data = data
      end

      def >(other)
        data.any? do |name, type|
          other_type = other[name]
          other_type.ancestors.include? type if type != other_type
        end
      end

      def collision?(other)
        self > other && other > self
      end

      def [](name)
        data[name]
      end

    private

      attr_reader :data
    end
  end
end
