require_relative 'helper'

class TestTypeclassBlock < Minitest::Test
  deftest :all do
    Foo = Typeclass.new a: Object, b: Object do
      should_raise(ArgumentError) { fn }
      should_raise(ArgumentError) { fn :foo }
      should_raise(ArgumentError) { fn :foo, [:a], :a }

      should_raise(NameError) { fn nil, [:a] }
      should_raise(NameError) { fn 1, [:a] }

      fn :foo, [:a]

      should_raise(NameError) { fn :foo, [:a] }

      should_raise(TypeError) { fn :bar, nil }
      should_raise(TypeError) { fn :bar, 1 }
      should_raise(TypeError) { fn :bar, :a }
      should_raise(TypeError) { fn :bar, 'a' }

      should_raise(TypeError) { fn :bar, [nil] }
      should_raise(TypeError) { fn :bar, [1] }
      should_raise(TypeError) { fn :bar, ['a'] }
      should_raise(TypeError) { fn :bar, [:a, 1] }
    end

    Foo.singleton_method :foo
    Foo.method :foo
  end
end
