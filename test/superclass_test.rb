require_relative 'helper'

class TestSuperclass < Minitest::Test
  Foo = Typeclass.new :a do
  end

  FooBar = Typeclass.new :a, :b do
  end

  def test_constructor # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    assert_raises(ArgumentError) { Foo[] }

    assert_raises(TypeError) { Foo[nil] }
    assert_raises(TypeError) { Foo[1] }
    assert_raises(TypeError) { Foo['a'] }
    assert_raises(TypeError) { Foo[[:a, :b]] }
    assert_raises(TypeError) { Foo[{ a: 1, b: 2 }] }

    assert_raises(ArgumentError) { Foo[:a, :b] }
    assert_raises(ArgumentError) { FooBar[:a] }

    foo_superclass = Foo[:a]
    foo_bar_superclass = FooBar[:a, :b]

    assert_kind_of Typeclass::Superclass, foo_superclass
    assert_kind_of Typeclass::Superclass, foo_bar_superclass

    assert_equal Foo, foo_superclass.typeclass
    assert_equal FooBar, foo_bar_superclass.typeclass

    assert_equal [:a], foo_superclass.args
    assert_equal [:a, :b], foo_bar_superclass.args
  end
end
