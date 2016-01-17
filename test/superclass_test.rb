require_relative 'helper'

class TestSuperclass < Minitest::Test
  Foo = Typeclass.new a: Object do
  end

  FooBar = Typeclass.new a: Object, b: Object do
  end

  def test_constructor
    assert_raises(ArgumentError) { Foo[] }
  end
end
