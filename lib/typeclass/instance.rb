class Typeclass < Module
  ##
  # Type class instance
  #
  class Instance
    attr_reader :params, :module

    def initialize(params, module_)
      @params = params
      @module = module_
    end

    def transmit(name, *args)
      self.module.send name, *args
    end

    def implements?(name)
      self.module.singleton_methods.include? name
    end

    def matched_by?(sig, args)
      sig.each_with_index.all? do |key, i|
        args[i].is_a? params[key]
      end
    end
  end
end
