# rubocop:disable Metrics/ClassLength

require_relative 'helper'

class TestBehavior < Minitest::Test
  deftest :all do
    Eq = Typeclass.new a: Object do
      fn :equals, [:a, :a] do |a1, a2|
        !noteq(a1, a2)
      end

      fn :noteq, [:a, :a] do |a1, a2|
        !equals(a1, a2)
      end
    end

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

    Eq1 = Struct.new(:n)
    Eq2 = Struct.new(:n)

    Typeclass.instance Eq, a: Eq1 do
      def equals(a1, a2)
        a1.n == a2.n
      end
    end

    Typeclass.instance Eq, a: Eq2 do
      def noteq(a1, a2)
        a1.n != a2.n
      end
    end

    assert_equal false, Eq.equals(Eq1[1], Eq1[2])
    assert_equal true, Eq.noteq(Eq1[1], Eq1[2])

    assert_equal false, Eq.equals(Eq2[1], Eq2[2])
    assert_equal true, Eq.noteq(Eq2[1], Eq2[2])

    module Bool; end

    class ::FalseClass # rubocop:disable Style/ClassAndModuleChildren
      include Bool
    end

    class ::TrueClass # rubocop:disable Style/ClassAndModuleChildren
      include Bool
    end

    Typeclass.instance Ord, a: Bool do
      V = { false => 0, true => 1 }

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

    Tst = Typeclass.new a: Object, b: Object do
      fn :foo, [:a, :b]
    end

    Typeclass.instance Tst, a: Numeric, b: Numeric do
      def foo(_a, _b)
        fail
      end
    end

    Typeclass.instance Tst, a: Numeric, b: Integer do
      def foo(_a, _b)
      end
    end

    Tst.foo(1.4, 1)

    A = Typeclass.new a: Object do
      fn :foo, [:a]

      fn :bar, []
      fn :car, [] {}
    end

    Typeclass.instance A, a: String do
      def bar
      end
    end

    assert_raises(ArgumentError) { A.foo }
    assert_raises(NoMethodError) { A.foo 'a' }
    assert_raises(NotImplementedError) { A.foo 1 }

    A.bar
    A.car

    B = Typeclass.new a: Object do
      fn :foo, [] do
        fail
      end
    end

    Typeclass.instance B, a: Object do
      def foo
      end
    end

    B.foo
  end
end
