# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestInstance
  deftest :all do
    Bar = Typeclass.new a: Integer, b: Enumerable, c: Comparable do end

    Typeclass.instance Bar, a: Integer, b: Hash, c: Integer do end
    Typeclass.instance Bar, a: Integer, b: Array, c: Integer do end

    Baz = Typeclass.new a: Object do end

    ##
    # Incorrect arguments count.
    #
    should_raise(ArgumentError) { Typeclass.instance do end }
    should_raise(ArgumentError) { Typeclass.instance Baz do end }
    should_raise(ArgumentError) {
      Typeclass.instance Baz, { a: Integer }, 1 do end
    }

    ##
    # No block given.
    #
    should_raise(LocalJumpError) { Typeclass.instance Baz, a: Integer }

    ##
    # First argument is not instance of Typeclass.
    #
    should_raise(TypeError) { Typeclass.instance nil, a: Integer do end }
    should_raise(TypeError) { Typeclass.instance :a, a: Integer do end }
    should_raise(TypeError) { Typeclass.instance 1, a: Integer do end }
    should_raise(TypeError) { Typeclass.instance 'a', a: Integer do end }
    should_raise(TypeError) { Typeclass.instance [], a: Integer do end }

    ##
    # Parameters are not presented as Hash.
    #
    should_raise(TypeError) { Typeclass.instance Baz, nil do end }
    should_raise(TypeError) { Typeclass.instance Baz, :a do end }
    should_raise(TypeError) { Typeclass.instance Baz, 1 do end }
    should_raise(TypeError) { Typeclass.instance Baz, 'a' do end }
    should_raise(TypeError) { Typeclass.instance Baz, [:a, :b] do end }

    ##
    # Parameter names do not match typeclass parameter names.
    #
    should_raise(ArgumentError) { Typeclass.instance Baz, {} do end }
    should_raise(ArgumentError) { Typeclass.instance Baz, b: Integer do end }
    should_raise(ArgumentError) {
      Typeclass.instance Baz, a: Integer, b: Integer do end
    }
    should_raise(ArgumentError) {
      Typeclass.instance Bar, a: Integer, b: Array do end
    }

    ##
    # Typeclass parameter types are no ancestors for instance parameter types.
    #
    should_raise(TypeError) {
      Typeclass.instance Bar, a: Integer, b: Array, c: Object do end
    }

    ##
    # Parameter collision.
    #
    Car = Typeclass.new a: Object, b: Object do end

    Typeclass.instance Car, a: Numeric, b: Integer do end
    should_raise(TypeError) {
      Typeclass.instance Car, a: Integer, b: Numeric do end
    }

    Cdr = Typeclass.new a: Object, b: Object do end

    cdr1 = Typeclass.instance Cdr, a: Numeric, b: Numeric do end
    cdr2 = Typeclass.instance Cdr, a: Integer, b: Integer do end
    cdr3 = Typeclass.instance Cdr, a: Integer, b: Numeric do end

    fail unless Cdr.instances == [cdr2, cdr3, cdr1]
  end
end

TestInstance.new.test_all
