# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestInstance < Minitest::Test
  Bar = Typeclass.new a: Integer, b: Enumerable, c: Comparable do end
  Baz = Typeclass.new a: Object do end

  deftest :arguments_count do
    assert_raises(ArgumentError) { Typeclass.instance do end }
    assert_raises(ArgumentError) { Typeclass.instance Baz do end }
    assert_raises(ArgumentError) {
      Typeclass.instance Baz, { a: Integer }, 1 do end
    }
  end

  deftest :block_given do
    assert_raises(LocalJumpError) { Typeclass.instance Baz, a: Integer }
  end

  deftest :first_argument_is_typeclass do
    assert_raises(TypeError) { Typeclass.instance nil, a: Integer do end }
    assert_raises(TypeError) { Typeclass.instance :a, a: Integer do end }
    assert_raises(TypeError) { Typeclass.instance 1, a: Integer do end }
    assert_raises(TypeError) { Typeclass.instance 'a', a: Integer do end }
    assert_raises(TypeError) { Typeclass.instance [], a: Integer do end }
  end

  deftest :parameters_are_presented_as_hash do
    assert_raises(TypeError) { Typeclass.instance Baz, nil do end }
    assert_raises(TypeError) { Typeclass.instance Baz, :a do end }
    assert_raises(TypeError) { Typeclass.instance Baz, 1 do end }
    assert_raises(TypeError) { Typeclass.instance Baz, 'a' do end }
    assert_raises(TypeError) { Typeclass.instance Baz, [:a, :b] do end }
  end

  deftest :parameter_names_match_typeclass_parameter_names do
    assert_raises(ArgumentError) { Typeclass.instance Baz, {} do end }
    assert_raises(ArgumentError) { Typeclass.instance Baz, b: Integer do end }
    assert_raises(ArgumentError) {
      Typeclass.instance Baz, a: Integer, b: Integer do end
    }
    assert_raises(ArgumentError) {
      Typeclass.instance Bar, a: Integer, b: Array do end
    }
  end

  deftest :typeclass_parameter_is_ancestor_for_instance_parameter do
    assert_raises(TypeError) {
      Typeclass.instance Bar, a: Integer, b: Array, c: Object do end
    }
  end

  deftest :collision_of_parameters do
    Car = Typeclass.new a: Object, b: Object do end

    Typeclass.instance Car, a: Numeric, b: Integer do end

    assert_raises(TypeError) {
      Typeclass.instance Car, a: Integer, b: Numeric do end
    }
  end

  deftest :instances_order do
    Cdr = Typeclass.new a: Object, b: Object do end

    cdr1 = Typeclass.instance Cdr, a: Numeric, b: Numeric do end
    cdr2 = Typeclass.instance Cdr, a: Integer, b: Integer do end
    cdr3 = Typeclass.instance Cdr, a: Integer, b: Numeric do end

    assert_equal [cdr2, cdr3, cdr1], Cdr.instances
  end

  deftest :instances_are_created_successful do
    Typeclass.instance Bar, a: Integer, b: Hash, c: Integer do end
    Typeclass.instance Bar, a: Integer, b: Array, c: Integer do end
  end
end
