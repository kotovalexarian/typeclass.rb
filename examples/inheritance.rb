require 'typeclass'

Foo = Typeclass.new :a do
  fn :foo, [:a]
end

Bar = Typeclass.new :a do
  include Foo[:a]

  fn :bar, [:a]
end

Typeclass.instance Foo, Integer do
  def foo(a)
    a * 2
  end
end

Typeclass.instance Bar, Integer do
  def bar(a)
    foo(a + 1)
  end
end

fail unless Bar.bar(2) == 6
