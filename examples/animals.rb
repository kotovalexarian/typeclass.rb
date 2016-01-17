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

fail unless talk(dog) == 'Spike says "woof woof!"'
fail unless talk(sheep) == 'Dolly says "baaah"'
