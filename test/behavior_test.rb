# rubocop:disable Metrics/ClassLength

require_relative 'helper'

class TestBehavior < Minitest::Test
  deftest :'1' do
    Eq = Typeclass.new a: Object do
      fn :equals, [:a, :a] do |a1, a2|
        !noteq(a1, a2)
      end

      fn :noteq, [:a, :a] do |a1, a2|
        !equals(a1, a2)
      end
    end

    Eq1 = Struct.new(:n)
    Eq2 = Struct.new(:n)

    Typeclass.instance Eq, Eq1 do
      def equals(a1, a2)
        a1.n == a2.n
      end
    end

    Typeclass.instance Eq, Eq2 do
      def noteq(a1, a2)
        a1.n != a2.n
      end
    end

    assert_equal false, Eq.equals(Eq1[1], Eq1[2])
    assert_equal true, Eq.noteq(Eq1[1], Eq1[2])

    assert_equal false, Eq.equals(Eq2[1], Eq2[2])
    assert_equal true, Eq.noteq(Eq2[1], Eq2[2])
  end

  deftest :'2' do
    Ord = Typeclass.new a: Object do
      fn :cmp, [:a, :a]

      fn :equals, [:a, :a] do |a1, a2|
        cmp(a1, a2).zero?
      end

      fn :noteq, [:a, :a] do |a1, a2|
        !cmp(a1, a2).zero?
      end

      fn :lesser, [:a, :a] do |a1, a2|
        cmp(a1, a2) < 0
      end

      fn :greater, [:a, :a] do |a1, a2|
        cmp(a1, a2) > 0
      end

      fn :lesseq, [:a, :a] do |a1, a2|
        cmp(a1, a2) <= 0
      end

      fn :greateq, [:a, :a] do |a1, a2|
        cmp(a1, a2) >= 0
      end
    end

    module Bool; end

    class ::FalseClass # rubocop:disable Style/ClassAndModuleChildren
      include Bool
    end

    class ::TrueClass # rubocop:disable Style/ClassAndModuleChildren
      include Bool
    end

    Typeclass.instance Ord, Bool do
      V = { false => 0, true => 1 }.freeze

      def cmp(a1, a2)
        V[a1] <=> V[a2]
      end
    end

    assert_equal true, Ord.equals(false, false)
    assert_equal false, Ord.equals(false, true)
    assert_equal false, Ord.noteq(true, true)
    assert_equal true, Ord.noteq(true, false)

    assert_equal true, Ord.lesser(false, true)
    assert_equal false, Ord.lesser(true, true)

    assert_equal false, Ord.greater(false, true)
    assert_equal false, Ord.greater(false, false)

    assert_equal true, Ord.lesseq(false, false)
    assert_equal false, Ord.lesseq(true, false)

    assert_equal true, Ord.greateq(true, true)
    assert_equal true, Ord.greateq(true, false)
  end

  deftest :choose_correct_instance_even_if_was_is_declared_later do
    Tst = Typeclass.new a: Object, b: Object do
      fn :foo, [:a, :b]
    end

    Typeclass.instance Tst, Numeric, Numeric do
      def foo(_a, _b)
        fail
      end
    end

    Typeclass.instance Tst, Numeric, Integer do
      def foo(_a, _b)
        :second
      end
    end

    assert_equal :second, Tst.foo(1.4, 1)
  end

  deftest :method_instantiates_correctly do
    A = Typeclass.new a: Object do
      fn :foo, [:a]

      fn :bar, []
      fn :car, [] { :car_result }
    end

    Typeclass.instance A, String do
      def bar
        :bar_result
      end
    end

    assert_raises(ArgumentError) { A.foo }
    assert_raises(NoMethodError) { A.foo 'a' }
    assert_raises(NotImplementedError) { A.foo 1 }

    assert_equal :bar_result, A.bar
    assert_equal :car_result, A.car
  end

  deftest :method_overloads_correclty do
    B = Typeclass.new a: Object do
      fn :foo, [] do
        fail
      end
    end

    Typeclass.instance B, Object do
      def foo
        :overloaded
      end
    end

    assert_equal :overloaded, B.foo
  end

  deftest :typeclass_is_visible_in_hidden_module do
    Foo = Typeclass.new a: Numeric do
      fn :foo, [:a]

      fn :bar, [:a] do |a|
        a * 2
      end
    end

    Typeclass.instance Foo, Integer do
      def foo(a)
        bar(a + 1)
      end
    end

    assert_equal 6, Foo.foo(2)
  end

  deftest :deep_inheritance do
    Bar = Typeclass.new a: Numeric do
      fn :bar, [:a] do |a|
        a * 2
      end
    end

    Car = Typeclass.new a: Object do
      include Bar[:a]

      fn :car, [:a]
    end

    Cdr = Typeclass.new a: Numeric do
      include Car[:a]

      fn :cdr, [:a] do |a|
        bar(a + 1)
      end

      fn :cdr2, [:a]
    end

    Typeclass.instance Bar, Integer do
    end

    Typeclass.instance Car, Integer do
    end

    Typeclass.instance Cdr, Integer do
      def cdr2(a)
        bar(a + 2)
      end
    end

    assert_equal 6, Cdr.cdr(2)
    assert_equal 8, Cdr.cdr2(2)
  end
end
