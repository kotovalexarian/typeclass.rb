require 'typeclass'

# Class Data.Eq from Haskell standard library
# https://hackage.haskell.org/package/base-4.8.1.0/docs/Data-Eq.html

Eq = Typeclass.new a: Object do
  fn :equal, [:a, :a] do |a1, a2|
    !noteq(a1, a2)
  end

  fn :noteq, [:a, :a] do |a1, a2|
    !equal(a1, a2)
  end
end

# Complex number

Cmplx = Struct.new(:real, :imag) do
  def self.scan(s)
    m = s.match(/^(?<real>\d+(\.\d+)?)\s*\+\s*(?<imag>\d+(\.\d+)?)i$/)
    Cmplx[m[:real].to_f, m[:imag].to_f]
  end

  def to_s
    "#{real} + #{imag}i"
  end
end

# Two complex numbers are equal if and only if
# both their real and imaginary parts are equal.

Typeclass.instance Eq, Cmplx do
  def equal(a1, a2)
    a1.real == a2.real && a1.imag == a2.imag
  end
end

include Eq

a = Cmplx[3.5, 2.7]

b = Cmplx.scan '3.5 + 2.7i'
c = Cmplx.scan '1.9 + 4.6i'

fail unless equal(b, a)
fail unless noteq(c, a)
