# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestInstance < Minitest::Test
  Bar = Typeclass.new :a, :b, :c, {
    a: Integer,
    b: Enumerable,
    c: Comparable,
  } do end

  Baz = Typeclass.new :a do end

  deftest :arguments_count do
    assert_raises(ArgumentError) { Typeclass.instance do end }
    assert_raises(ArgumentError) { Typeclass.instance Baz do end }
  end

  deftest :block_given do
    assert_raises(LocalJumpError) { Typeclass.instance Baz, Integer }
  end

  deftest :first_argument_is_typeclass do
    assert_raises(TypeError) { Typeclass.instance nil, Integer do end }
    assert_raises(TypeError) { Typeclass.instance :a, Integer do end }
    assert_raises(TypeError) { Typeclass.instance 1, Integer do end }
    assert_raises(TypeError) { Typeclass.instance 'a', Integer do end }
    assert_raises(TypeError) { Typeclass.instance [], Integer do end }
  end

  deftest :parameters_are_types do
    assert_raises(TypeError) { Typeclass.instance Baz, nil do end }
    assert_raises(TypeError) { Typeclass.instance Baz, :a do end }
    assert_raises(TypeError) { Typeclass.instance Baz, 1 do end }
    assert_raises(TypeError) { Typeclass.instance Baz, 'a' do end }
    assert_raises(TypeError) { Typeclass.instance Baz, [:a, :b] do end }
  end

  deftest :typeclass_parameter_is_ancestor_for_instance_parameter do
    assert_raises(TypeError) {
      Typeclass.instance Bar, Integer, Array, Object do end
    }
  end

  deftest :collision_of_parameters do
    Car = Typeclass.new :a, :b do end

    Typeclass.instance Car, Numeric, Integer do end

    assert_raises(TypeError) {
      Typeclass.instance Car, Integer, Numeric do end
    }
  end

  deftest :instances_order do
    Cdr = Typeclass.new :a, :b do end

    cdr1 = Typeclass.instance Cdr, Numeric, Numeric do end
    cdr2 = Typeclass.instance Cdr, Integer, Integer do end
    cdr3 = Typeclass.instance Cdr, Integer, Numeric do end

    assert_equal [cdr2, cdr3, cdr1], Cdr.send(:instances)
  end

  deftest :instances_are_created_successful do
    Typeclass.instance Bar, Integer, Hash, Integer do end
    Typeclass.instance Bar, Integer, Array, Integer do end
  end

  deftest :instances_are_created_successful_with_alternative_syntax do
    Bar.instance Integer, Hash, Float do end
    Bar.instance Integer, Array, Float do end
  end

  deftest :instantiation_checks_if_superclasses_are_implemented do
    ImplementedSuperclass = Typeclass.new :a do end
    NotImplementedSuperclass = Typeclass.new :a do end

    Typeclass.instance ImplementedSuperclass, Integer do end
    Typeclass.instance NotImplementedSuperclass, String do end

    SomeTypeclass = Typeclass.new :a do
      include ImplementedSuperclass[:a]
      include NotImplementedSuperclass[:a]
    end

    assert_raises(NotImplementedError) do
      Typeclass.instance SomeTypeclass, Integer do end
    end
  end
end
