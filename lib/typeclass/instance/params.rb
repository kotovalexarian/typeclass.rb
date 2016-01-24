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

      def self.pos_to_raw!(pos_params, constraints)
        fail ArgumentError if pos_params.empty?

        pos_params.each_with_index.map do |param, index|
          fail TypeError unless Typeclass.type? param
          { constraints.keys[index] => param }
        end.inject(&:merge)
      end

      def self.check_raw_params!(raw_params, # rubocop:disable Metrics/AbcSize
                                 constraints)
        fail TypeError unless raw_params.is_a? Hash
        fail ArgumentError unless (constraints.keys - raw_params.keys).empty?
        fail ArgumentError unless (raw_params.keys - constraints.keys).empty?

        fail TypeError unless raw_params.all? do |name, type|
          (type.ancestors + [BASE_CLASS]).include? constraints[name]
        end
      end
    end
  end
end
