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

      return instance.transmit name, *args if instance.implements? name
      return block.call(*args) if block
      fail NoMethodError
    end

    def to_proc
      method(:call)
    end

  private

    attr_reader :typeclass, :name, :sig, :block
  end
end
