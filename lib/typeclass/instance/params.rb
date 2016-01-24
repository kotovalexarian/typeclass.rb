class Typeclass < Module
  class Instance
    ##
    # Named type parameters for type class instance.
    #
    class Params
      attr_reader :data

      def initialize(raw_params)
        @data = raw_params
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

      def self.pos_to_raw!(pos_params, # rubocop:disable Metrics/AbcSize
                           constraints)
        fail ArgumentError unless pos_params.count == constraints.count

        pos_params.each_with_index.map do |param, index|
          fail TypeError unless Typeclass.type? param and
                                (param.ancestors + [BASE_CLASS]).include?(
                                  constraints[constraints.keys[index]])

          { constraints.keys[index] => param }
        end.inject(&:merge)
      end
    end
  end
end
