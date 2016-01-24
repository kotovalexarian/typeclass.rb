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
      # @!attribute [r] instances
      # @return [Array<Typeclass::Instance>] Type class instances.
      # @api private
      def instances
        @instances ||= []
      end

      # Create new instance of type class.
      #
      # @example
      #   Formatter = Typeclass.new a: Object do
      #     fn :format, [:a]
      #   end
      #
      #   Formatter.instance Integer do
      #     def format(a)
      #       "exactly #{a}"
      #     end
      #   end
      #
      #   Formatter.instance Float do
      #     def format(a)
      #       "about #{a.round 2}"
      #     end
      #   end
      #
      # @param pos_params [Array<Class>] Type parameters.
      # @yield Opens module for function implementations.
      # @return [Typeclass::Instance] New instance of type class.
      #
      # @note
      #   Exceptions raised by this method should stay unhandled.
      #
      def instance(*pos_params, &block)
        fail LocalJumpError, 'no block given' unless block_given?

        raw_params = Instance::Params.pos_to_raw! pos_params, constraints

        check_superclasses_implemented! raw_params

        params = Instance::Params.new(raw_params)
        index = get_index! params

        hidden_module = Instance::HiddenModule.new(self, &block)

        instance = Instance.new(params, hidden_module)
        instances.insert index, instance

        instance
      end

      # Get type class instance for function with signature `sig`
      # when it was called with arguments `args`.
      #
      # @param sig [Array<Symbol>] Function signature.
      # @param args [Array] Function arguments.
      # @return [Typeclass::Instance, nil] Type class instance if match found.
      #
      # @api private
      #
      def get_instance(sig, args)
        instances.each do |instance|
          return instance if instance.matched_by? sig, args
        end

        nil
      end

      # Get index for new instance in array of instances.
      #
      # @param params [Typeclass::Params] Type parameters.
      # @return [Integer] Index for new instance in array of instances.
      #
      # @raise [TypeError] Collision with existing instance.
      #
      # @api private
      #
      def get_index!(params)
        (0..instances.count).each do |i|
          instance = instances[i]
          return i if instance.nil?
          fail TypeError if instance.params.collision? params
          return i if instance.params > params
        end
      end

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
        # @param pos_params [Array<Class>] Type parameters.
        # @yield Opens module for function implementations.
        # @return [Typeclass::Instance] New instance of type class.
        #
        # @note
        #   Exceptions raised by this method should stay unhandled.
        #
        def instance(typeclass, *pos_params, &block)
          fail TypeError unless typeclass.is_a? Typeclass

          typeclass.instance(*pos_params, &block)
        end
      end
    end
  end
end
