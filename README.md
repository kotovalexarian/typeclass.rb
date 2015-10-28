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
