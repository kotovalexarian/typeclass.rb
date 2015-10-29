# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestTypeclassBlock < Minitest::Test
  deftest :all do
    assert_raises(ArgumentError) {
      Typeclass.new a: Object do
        fn
      end
    }

    assert_raises(ArgumentError) {
      Typeclass.new a: Object do
        fn :foo
      end
    }

    assert_raises(ArgumentError) {
      Typeclass.new a: Object do
        fn :foo, [:a], :a
      end
    }

    assert_raises(NameError) {
      Typeclass.new a: Object do
        fn nil, [:a]
      end
    }

    assert_raises(NameError) {
      Typeclass.new a: Object do
        fn 1, [:a]
      end
    }

    assert_raises(NameError) {
      Typeclass.new a: Object do
        fn :foo, [:a]
        fn :foo, [:a]
      end
    }

    assert_raises(TypeError) {
      Typeclass.new a: Object do
        fn :bar, nil
      end
    }

    assert_raises(TypeError) {
      Typeclass.new a: Object do
        fn :bar, 1
      end
    }

    assert_raises(TypeError) {
      Typeclass.new a: Object do
        fn :bar, :a
      end
    }

    assert_raises(TypeError) {
      Typeclass.new a: Object do
        fn :bar, 'a'
      end
    }

    assert_raises(TypeError) {
      Typeclass.new a: Object do
        fn :bar, [nil]
      end
    }

    assert_raises(TypeError) {
      Typeclass.new a: Object do
        fn :bar, [1]
      end
    }

    assert_raises(TypeError) {
      Typeclass.new a: Object do
        fn :bar, ['a']
      end
    }

    assert_raises(TypeError) {
      Typeclass.new a: Object do
        fn :bar, [:a, 1]
      end
    }

    Foo = Typeclass.new a: Object do
      fn :foo, []
    end

    Foo.singleton_method :foo
    Foo.method :foo
  end
end
