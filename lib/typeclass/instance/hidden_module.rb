class Typeclass < Module
  class Instance
    ##
    # Hidden module for type class instance.
    #
    class HiddenModule
      attr_reader :module

      def initialize(typeclass, &block)
        @module = Module.new

        self.module.send :include, typeclass
        self.module.instance_exec(&block)
      end
    end
  end
end
