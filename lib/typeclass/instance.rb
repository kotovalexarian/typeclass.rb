require 'typeclass/instance/params'
require 'typeclass/instance/hidden_module'

class Typeclass < Module
  ##
  # Type class instance.
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

    ##
    # Typeclass extension for instances.
    #
    module TypeclassMixin
      ##
      # Typeclass extension for instances
      # (class methods).
      #
      module ClassMethods
        # Create new instance of type class.
        #
        # @see #instance
        #
        # @param typeclass [Typeclass] Type class.
        # @param raw_params [Hash] Type parameters.
        # @yield Opens module for function implementations.
        # @return [Typeclass::Instance] New instance of type class.
        #
        # @note
        #   Exceptions raised by this method should stay unhandled.
        #
        def instance(typeclass, raw_params, &block)
          fail TypeError unless typeclass.is_a? Typeclass

          typeclass.instance raw_params, &block
        end
      end
    end
  end
end
