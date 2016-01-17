require_relative 'helper'

class TestSuperclass < Minitest::Test
  Foo = Typeclass.new a: Object do
  end

  FooBar = Typeclass.new a: Object, b: Object do
  end

  def test_constructor # rubocop:disable Metrics/AbcSize
    assert_raises(ArgumentError) { Foo[] }

    assert_raises(TypeError) { Foo[nil] }
    assert_raises(TypeError) { Foo[1] }
    assert_raises(TypeError) { Foo['a'] }
    assert_raises(TypeError) { Foo[[:a, :b]] }
    assert_raises(TypeError) { Foo[{ a: 1, b: 2 }] }

    assert_raises(ArgumentError) { Foo[:a, :b] }
    assert_raises(ArgumentError) { FooBar[:a] }
  end
end
