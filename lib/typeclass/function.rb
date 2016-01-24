class Typeclass < Module
  ##
  # Generic function.
  #
  class Function
    attr_reader :typeclass, :name, :sig, :block

    def initialize(typeclass, name, sig, &block)
      @typeclass = typeclass
      @name = name
      @sig = sig
      @block = block
    end

    def call(*args) # rubocop:disable Metrics/AbcSize
      fail ArgumentError if sig.length != args.count

      instance = typeclass.get_instance sig, args

      fail NotImplementedError unless instance

      return instance.transmit name, *args if instance.implements? name
      return block.call(*args) if block
      fail NoMethodError
    end

    def to_proc
      method(:call)
    end

    ##
    # Typeclass extension for function.
    #
    module TypeclassMixin
      # @!attribute [r] functions
      # @return [Array<Typeclass::Function>] Typeclass' functions.
      # @api private
      def functions
        @functions ||= []
      end

      # Declare function signature with optional default block.
      #
      # @example
      #   Foo = Typeclass.new a: Enumerable do
      #     fn :no_default, [:a]
      #     fn :with_default, [:a] do |a|
      #       a.first
      #     end
      #   end
      #
      #   Foo.instance a: Array do end
      #
      #   Foo.with_default ['a', 'b', 'c'] #=> "a"
      #   Foo.no_defalt ['a', 'b', 'c']    # raises `NoMethodError`
      #
      # @param name [Symbol, String] Function name.
      # @param sig [Array<Symbol>] Function signature.
      # @yield Optional default block.
      #
      # @note
      #   Exceptions raised by this method should stay unhandled.
      #
      def fn(name, sig, &block)
        name = name.to_sym rescue (raise NameError)
        fail NameError if method_defined? name
        fail TypeError unless sig.is_a? Array
        fail TypeError unless sig.all? { |item| item.is_a? Symbol }

        functions << f = Function.new(self, name, sig, &block)

        p = f.to_proc

        define_singleton_method name, &p
        define_method name, &p
      end
    end
  end
end
