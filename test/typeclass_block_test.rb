# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestTypeclassBlock < Minitest::Test
  deftest :fn_arguments_count do
    assert_raises(ArgumentError) {
      Typeclass.new :a do
        fn
      end
    }

    assert_raises(ArgumentError) {
      Typeclass.new :a do
        fn :foo
      end
    }

    assert_raises(ArgumentError) {
      Typeclass.new :a do
        fn :foo, [:a], :a
      end
    }
  end

  deftest :fn_method_name do
    assert_raises(NameError) {
      Typeclass.new :a do
        fn nil, [:a]
      end
    }

    assert_raises(NameError) {
      Typeclass.new :a do
        fn 1, [:a]
      end
    }

    assert_raises(NameError) {
      Typeclass.new :a do
        fn :foo, [:a]
        fn :foo, [:a]
      end
    }
  end

  deftest :fn_method_arguments_list do
    assert_raises(TypeError) {
      Typeclass.new :a do
        fn :bar, nil
      end
    }

    assert_raises(TypeError) {
      Typeclass.new :a do
        fn :bar, 1
      end
    }

    assert_raises(TypeError) {
      Typeclass.new :a do
        fn :bar, :a
      end
    }

    assert_raises(TypeError) {
      Typeclass.new :a do
        fn :bar, 'a'
      end
    }

    assert_raises(TypeError) {
      Typeclass.new :a do
        fn :bar, [nil]
      end
    }

    assert_raises(TypeError) {
      Typeclass.new :a do
        fn :bar, [1]
      end
    }

    assert_raises(TypeError) {
      Typeclass.new :a do
        fn :bar, ['a']
      end
    }

    assert_raises(TypeError) {
      Typeclass.new :a do
        fn :bar, [:a, 1]
      end
    }
  end

  deftest :fn_created_method do
    Foo = Typeclass.new :a do
      fn :foo, []
    end

    assert_kind_of Method, Foo.method(:foo)
    assert_kind_of UnboundMethod, Foo.instance_method(:foo)
  end
end
