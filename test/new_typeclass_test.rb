# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestNewTypeclass < Minitest::Test
  deftest :block_given do
    assert_raises(LocalJumpError) { Typeclass.new a: Object }
  end

  deftest :parameters_are_presented_as_hash do
    assert_raises(TypeError) { Typeclass.new nil do end }
    assert_raises(TypeError) { Typeclass.new :a do end }
    assert_raises(TypeError) { Typeclass.new 1 do end }
    assert_raises(TypeError) { Typeclass.new 'a' do end }
    assert_raises(TypeError) { Typeclass.new [:a, :b] do end }
  end

  deftest :at_least_one_parameter_exist do
    assert_raises(ArgumentError) { Typeclass.new({}) do end }
  end

  deftest :parameter_name do
    assert_raises(TypeError) { Typeclass.new 'a' => Object do end }
  end

  deftest :parameter_value do
    assert_raises(TypeError) { Typeclass.new a: nil do end }
    assert_raises(TypeError) { Typeclass.new a: Object, b: :a do end }
    assert_raises(TypeError) { Typeclass.new a: 1 do end }
    assert_raises(TypeError) { Typeclass.new a: 'Object' do end }
    assert_raises(TypeError) { Typeclass.new a: [Symbol, String] do end }
  end

  deftest :typeclass_is_module do
    assert_kind_of Module, (Typeclass.new a: Object do end)
  end

  deftest :typeclass_is_created_successful do
    Typeclass.new a: Integer, b: String do end
  end

  deftest :typeclass_checks_if_arguments_are_superclasses do
    Car = Typeclass.new a: Integer do end

    assert_raises(TypeError) { Typeclass.new nil, a: Object do end }
    assert_raises(TypeError) { Typeclass.new 1, a: Object do end }
    assert_raises(TypeError) { Typeclass.new :a, a: Object do end }
    assert_raises(TypeError) { Typeclass.new 'a', a: Object do end }
    assert_raises(TypeError) { Typeclass.new [Car[:a]], a: Object do end }
    assert_raises(TypeError) { Typeclass.new({ a: Object }, a: Object) do end }
  end

  deftest :typeclass_checks_superclass_arguments do
    Cdr = Typeclass.new a: Object do end

    assert_raises(ArgumentError) { Typeclass.new Cdr[:a], b: Object do end }
  end

  deftest :typeclass_with_superclass_is_created_successful do
    Foo = Typeclass.new a: Integer do end
    Bar = Typeclass.new a: String do end

    FooBar = Typeclass.new Foo[:a], Bar[:b], a: Object, b: Object do end

    assert_equal 2, FooBar.send(:superclasses).count

    assert_instance_of Typeclass::Superclass, FooBar.send(:superclasses)[0]
    assert_instance_of Typeclass::Superclass, FooBar.send(:superclasses)[1]

    assert_equal Foo, FooBar.send(:superclasses)[0].typeclass
    assert_equal Bar, FooBar.send(:superclasses)[1].typeclass

    assert_equal [:a], FooBar.send(:superclasses)[0].args
    assert_equal [:b], FooBar.send(:superclasses)[1].args
  end
end
