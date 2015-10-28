Typeclass
=========

[![Gem Version](https://badge.fury.io/rb/typeclass.svg)](http://badge.fury.io/rb/typeclass)
[![Build Status](https://travis-ci.org/braiden-vasco/typeclass.rb.svg)](https://travis-ci.org/braiden-vasco/typeclass.rb)
[![Coverage Status](https://coveralls.io/repos/braiden-vasco/typeclass.rb/badge.svg)](https://coveralls.io/r/braiden-vasco/typeclass.rb)

Haskell type classes in Ruby.

Examples
--------

```ruby
# This comes from Rust traits example
# http://rustbyexample.com/trait.html

require 'typeclass'

Animal = Typeclass.new a: Object do
  fn :name, [:a]
  fn :noise, [:a]

  fn :talk, [:a] do |a|
    "#{name a} says \"#{noise a}\""
  end
end

Dog = Struct.new(:name)

Typeclass.instance Animal, a: Dog do
  def name(a)
    a.name
  end

  def noise(_a)
    'woof woof!'
  end
end

Sheep = Struct.new(:name)

Typeclass.instance Animal, a: Sheep do
  def name(a)
    a.name
  end

  def noise(_a)
    'baaah'
  end
end

include Animal

dog = Dog['Spike']
sheep = Sheep['Dolly']

puts talk(dog) # Spike says "woof woof!"
puts talk(sheep) # Dolly says "baaah"

```

```ruby
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

Typeclass.instance Eq, a: Cmplx do
  def equal(a1, a2)
    a1.real == a2.real && a1.imag == a2.imag
  end
end

include Eq

a = Cmplx[3.5, 2.7]

b = Cmplx.scan '3.5 + 2.7i'
c = Cmplx.scan '1.9 + 4.6i'

puts "#{b} == #{a}" if equal(b, a) # 3.5 + 2.7i == 3.5 + 2.7i
puts "#{c} != #{a}" if noteq(c, a) # 1.9 + 4.6i != 3.5 + 2.7i

```
