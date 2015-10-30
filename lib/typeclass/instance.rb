require 'typeclass/instance/params'
require 'typeclass/instance/hidden_module'

class Typeclass < Module
  ##
  # Type class instance
  #
  class Instance
    attr_reader :params, :hidden_module

    def initialize(params, hidden_module)
      @params = params
      @hidden_module = hidden_module
    end

    def transmit(name, *args)
      hidden_module.module.send name, *args
    end

    def implements?(name)
      hidden_module.module.singleton_methods.include? name
    end

    def matched_by?(sig, args)
      sig.each_with_index.all? do |key, i|
        args[i].is_a? params[key]
      end
    end
  end
end
