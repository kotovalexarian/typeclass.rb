# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestNewTypeclass < Minitest::Test
  deftest :all do
    ##
    # Incorrect arguments count.
    #
    assert_raises(ArgumentError) { Typeclass.new }
    assert_raises(ArgumentError) { Typeclass.new 1, a: Object do end }

    ##
    # No block given.
    #
    assert_raises(LocalJumpError) { Typeclass.new a: Object }

    ##
    # Parameters are not presented as Hash.
    #
    assert_raises(TypeError) { Typeclass.new nil do end }
    assert_raises(TypeError) { Typeclass.new :a do end }
    assert_raises(TypeError) { Typeclass.new 1 do end }
    assert_raises(TypeError) { Typeclass.new 'a' do end }
    assert_raises(TypeError) { Typeclass.new [:a, :b] do end }

    ##
    # No parameters are presented.
    #
    assert_raises(ArgumentError) { Typeclass.new({}) do end }

    ##
    # Parameter name in not a symbol.
    #
    assert_raises(TypeError) { Typeclass.new 'a' => Object do end }

    ##
    # Parameter has incorrect type.
    #
    assert_raises(TypeError) { Typeclass.new a: nil do end }
    assert_raises(TypeError) { Typeclass.new a: Object, b: :a do end }
    assert_raises(TypeError) { Typeclass.new a: 1 do end }
    assert_raises(TypeError) { Typeclass.new a: 'Object' do end }
    assert_raises(TypeError) { Typeclass.new a: [Symbol, String] do end }

    ##
    # Typeclass is module.
    #
    fail unless (Typeclass.new a: Object do end).is_a? Module

    Typeclass.new a: Integer, b: String do end
  end
end
