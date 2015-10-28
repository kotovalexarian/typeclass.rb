# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestNewTypeclass
  deftest :all do
    ##
    # Incorrect arguments count.
    #
    should_raise(ArgumentError) { Typeclass.new }
    should_raise(ArgumentError) { Typeclass.new 1, a: Object do end }

    ##
    # No block given.
    #
    should_raise(LocalJumpError) { Typeclass.new a: Object }

    ##
    # Parameters are not presented as Hash.
    #
    should_raise(TypeError) { Typeclass.new nil do end }
    should_raise(TypeError) { Typeclass.new :a do end }
    should_raise(TypeError) { Typeclass.new 1 do end }
    should_raise(TypeError) { Typeclass.new 'a' do end }
    should_raise(TypeError) { Typeclass.new [:a, :b] do end }

    ##
    # No parameters are presented.
    #
    should_raise(ArgumentError) { Typeclass.new({}) do end }

    ##
    # Parameter name in not a symbol.
    #
    should_raise(TypeError) { Typeclass.new 'a' => Object do end }

    ##
    # Parameter has incorrect type.
    #
    should_raise(TypeError) { Typeclass.new a: nil do end }
    should_raise(TypeError) { Typeclass.new a: Object, b: :a do end }
    should_raise(TypeError) { Typeclass.new a: 1 do end }
    should_raise(TypeError) { Typeclass.new a: 'Object' do end }
    should_raise(TypeError) { Typeclass.new a: [Symbol, String] do end }

    ##
    # Typeclass is module.
    #
    fail unless (Typeclass.new a: Object do end).is_a? Module

    Typeclass.new a: Integer, b: String do end
  end
end

TestNewTypeclass.new.test_all
