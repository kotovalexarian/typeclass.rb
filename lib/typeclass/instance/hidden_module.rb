class Typeclass < Module
  class Instance
    ##
    # Hidden module for type class instance.
    #
    class HiddenModule
      attr_reader :module

      def initialize(typeclass, &block)
        @module = Module.new

        self.module.instance_exec(&block)

        self.module.define_singleton_method :method_missing do |name, *args|
          typeclass.send name, *args
        end
      end
    end
  end
end
