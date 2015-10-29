class Typeclass < Module # rubocop:disable Style/Documentation
  Instance = Struct.new(:params, :module) do
    def transmit(name, *args)
      self.module.send name, *args
    end

    def implements?(name)
      self.module.singleton_methods.include? name
    end
  end
end
