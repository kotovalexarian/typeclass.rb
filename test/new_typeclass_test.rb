# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestNewTypeclass < Minitest::Test
  deftest :block_given do
    assert_raises(LocalJumpError) { Typeclass.new :a }
  end

  deftest :parameters_are_symbols do
    assert_raises(TypeError) { Typeclass.new nil do end }
    assert_raises(TypeError) { Typeclass.new 1 do end }
    assert_raises(TypeError) { Typeclass.new 'a' do end }
    assert_raises(TypeError) { Typeclass.new [:a, :b] do end }
  end

  deftest :at_least_one_parameter_exist do
    assert_raises(ArgumentError) { Typeclass.new do end }
  end

  deftest :constraint_name do
    assert_raises(ArgumentError) { Typeclass.new :a, b: Object do end }
  end

  deftest :constraint_value do
    assert_raises(TypeError) { Typeclass.new :a, a: nil do end }
    assert_raises(TypeError) { Typeclass.new :a, :b, a: Object, b: :a do end }
    assert_raises(TypeError) { Typeclass.new :a, a: 1 do end }
    assert_raises(TypeError) { Typeclass.new :a, a: 'Object' do end }
    assert_raises(TypeError) { Typeclass.new :a, a: [Symbol, String] do end }
  end

  deftest :typeclass_is_module do
    assert_kind_of Module, (Typeclass.new :a do end)
  end

  deftest :typeclass_is_created_successful do
    Typeclass.new :a, :b do end
    Typeclass.new :a, :b, a: Integer, b: String do end
  end

  deftest :typeclass_has_functions do
    ABCD = Typeclass.new :a do
      fn :qwe, [:a]
      fn :rty, [:a, :a] do |a1, a2|
        [a1, a2]
      end
    end

    assert_equal 2, ABCD.functions.count

    assert_instance_of Typeclass::Function, ABCD.functions[0]
    assert_instance_of Typeclass::Function, ABCD.functions[1]

    assert_equal ABCD, ABCD.functions[0].typeclass
    assert_equal ABCD, ABCD.functions[1].typeclass

    assert_equal :qwe, ABCD.functions[0].name
    assert_equal :rty, ABCD.functions[1].name

    assert_equal [:a], ABCD.functions[0].sig
    assert_equal [:a, :a], ABCD.functions[1].sig

    assert_equal nil, ABCD.functions[0].block
    assert_equal [123, 456], ABCD.functions[1].block.call(123, 456)
  end

  deftest :typeclass_checks_superclass_arguments do
    Cdr = Typeclass.new :a do end

    assert_raises(ArgumentError) do
      Typeclass.new :b do
        include Cdr[:a]
      end
    end
  end

  deftest :typeclass_with_superclass_is_created_successful do
    Foo = Typeclass.new :a, a: Integer do end
    Bar = Typeclass.new :a, a: String do end

    FooBar = Typeclass.new :a, :b do
      include Foo[:a]
      include Bar[:b]
    end

    assert_equal 2, FooBar.send(:superclasses).count

    assert_instance_of Typeclass::Superclass, FooBar.send(:superclasses)[0]
    assert_instance_of Typeclass::Superclass, FooBar.send(:superclasses)[1]

    assert_equal Foo, FooBar.send(:superclasses)[0].typeclass
    assert_equal Bar, FooBar.send(:superclasses)[1].typeclass

    assert_equal [:a], FooBar.send(:superclasses)[0].args
    assert_equal [:b], FooBar.send(:superclasses)[1].args
  end
end
