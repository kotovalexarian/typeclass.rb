# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestInstance < Minitest::Test
  Bar = Typeclass.new(
    :a, :b, :c,
    a: Integer,
    b: Enumerable,
    c: Comparable,
  ) do end

  Baz = Typeclass.new :a do end

  deftest :arguments_count do
    assert_raises(ArgumentError) { Baz.instance do end }
  end

  deftest :block_given do
    assert_raises(LocalJumpError) { Baz.instance Integer }
  end

  deftest :parameters_are_types do
    assert_raises(TypeError) { Baz.instance nil do end }
    assert_raises(TypeError) { Baz.instance :a do end }
    assert_raises(TypeError) { Baz.instance 1 do end }
    assert_raises(TypeError) { Baz.instance 'a' do end }
    assert_raises(TypeError) { Baz.instance [:a, :b] do end }
  end

  deftest :typeclass_parameter_is_ancestor_for_instance_parameter do
    assert_raises(TypeError) {
      Bar.instance Integer, Array, Object do end
    }
  end

  deftest :collision_of_parameters do
    Car = Typeclass.new :a, :b do end

    Car.instance Numeric, Integer do end

    assert_raises(TypeError) {
      Car.instance Integer, Numeric do end
    }
  end

  deftest :instances_order do
    Cdr = Typeclass.new :a, :b do end

    cdr1 = Cdr.instance Numeric, Numeric do end
    cdr2 = Cdr.instance Integer, Integer do end
    cdr3 = Cdr.instance Integer, Numeric do end

    assert_equal [cdr2, cdr3, cdr1], Cdr.send(:instances)
  end

  deftest :instances_are_created_successful do
    Bar.instance Integer, Hash, Integer do end
    Bar.instance Integer, Array, Integer do end
    Bar.instance Integer, Hash, Float do end
    Bar.instance Integer, Array, Float do end
  end

  deftest :instantiation_checks_if_superclasses_are_implemented do
    ImplementedSuperclass = Typeclass.new :a do end
    NotImplementedSuperclass = Typeclass.new :a do end

    ImplementedSuperclass.instance Integer do end
    NotImplementedSuperclass.instance String do end

    SomeTypeclass = Typeclass.new :a do
      include ImplementedSuperclass[:a]
      include NotImplementedSuperclass[:a]
    end

    assert_raises(NotImplementedError) do
      SomeTypeclass.instance Integer do end
    end
  end
end
