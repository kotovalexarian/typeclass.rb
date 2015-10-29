class Typeclass < Module # rubocop:disable Style/Documentation
  Params = Struct.new(:data) do
    def >(other)
      data.any? do |name, type|
        other_type = other.data[name]
        other_type.ancestors.include? type if type != other_type
      end
    end

    def collision?(other)
      self > other && other > self
    end
  end
end
