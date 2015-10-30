class Typeclass < Module
  ##
  # Generic function.
  #
  class Function
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

      if instance.implements? name
        instance.transmit name, *args
      elsif block
        block.call(*args)
      else
        fail NoMethodError
      end
    end

    def to_proc
      method(:call)
    end

  private

    attr_reader :typeclass, :name, :sig, :block
  end
end
