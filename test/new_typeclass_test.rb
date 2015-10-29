# rubocop:disable Style/BlockDelimiters

require_relative 'helper'

class TestNewTypeclass < Minitest::Test
  deftest :arguments_count do
    assert_raises(ArgumentError) { Typeclass.new }
    assert_raises(ArgumentError) { Typeclass.new 1, a: Object do end }
  end

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
end
