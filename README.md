Typeclass
=========

[![Gem Version](https://badge.fury.io/rb/typeclass.svg)](http://badge.fury.io/rb/typeclass)
[![Build Status](https://travis-ci.org/braiden-vasco/typeclass.rb.svg)](https://travis-ci.org/braiden-vasco/typeclass.rb)
[![Coverage Status](https://coveralls.io/repos/braiden-vasco/typeclass.rb/badge.svg)](https://coveralls.io/r/braiden-vasco/typeclass.rb)
[![Inline docs](http://inch-ci.org/github/braiden-vasco/typeclass.rb.svg?branch=master)](http://inch-ci.org/github/braiden-vasco/typeclass.rb)

Haskell type classes in Ruby.

Summary
-------

Current state:

* Syntactic identity with Haskell type classes

Goals:

* Static type checking
* Strong optimization

Usage
-----

**The gem is under development. Don't try to use it in production code.**

To install type in terminal

```sh
gem install typeclass
```

or add to your `Gemfile`

```ruby
gem 'typeclass', '~> 0.1.1'
```

To learn how to use the gem look at the [examples](/examples/).

Concept
-------

The main goals of this project is to create statically typed subset of Ruby
inside dynamically typed Ruby programs as a set of functions which know
types of it's arguments. There is something like function decorator
which checks if function is correctly typed after it is defined.
Type declarations are needed for typeclass definition only. All other types
are known due to type inference, so the code looks like normal Ruby code.

Of course there is a runtime overhead due to the use of type classes.
Therefore another important goal is an optimiaztion which is possible
because of the known types. It can be performed with bytecode generation
at runtime. In this way the bytecode generated by Ruby interpreter
will be replaced with the optimized code generated directly from the source.
If the optimized bytecode can not be generated due to some reasons
(no back end for the virtual machine, for example), the code can be
interpreted in the usual way because it is still a normal Ruby code.

Example
-------

Please read [this article](https://www.haskell.org/tutorial/classes.html)
if you are unfamiliar with Haskell type classes (understanding of Rust
traits should be enough).

Let's look at the following example and realize which parts of the code
can be statically typed.

```ruby
Show = Typeclass.new a: Object do
  fn :show, [:a]
end

Typeclass.instance Show, a: Integer do
  def show(a)
    "Integer(#{a})"
  end
end

Typeclass.instance Show, a: String do
  def show(a)
    "String(#{a.dump})"
  end
end

puts Show.show(5) #=> Integer(5)
puts Show.show('Qwerty') #=> String("Qwerty")
```

As you can see, that there is no annoying
[typesig's](https://rubygems.org/gems/rubype),
[typecheck's](https://rubygems.org/gems/typecheck),
[sig's](https://rubygems.org/gems/sig),
and again [typesig's](https://github.com/plum-umd/rtc).
Definitions of type classes and instances, and function signatures
looks like typical Haskell code. The functions, in turn, are just
Ruby methods.

Nevertheless, the types of the arguments are known and can be checked
in `Typeclass#instance` method after it's block is executed.

Optimizations
-------------

### Interaction between parts of the code

There are a few options how the statically and dynamically typed
parts of code interact with one another.

* statically typed code calls dynamically typed code
* dynamically typed code calls statically typed code
* statically typed code calls statically typed code

Let's look at each separately.

#### Statically typed code calls dynamically typed code

```ruby
Foo = Typeclass.new a: Object, b: Object do
  fn :foo, [:a, :b]
end

class Bar
  def bar(b)
    # ...
  end
end

Typeclass.instance Foo, a: Bar, b: Integer do
  def foo(a, b)
    a.bar(b)
  end
end
```

In this case we can not know how method `Bar#bar` uses it's arguments,
so we can only call the method without any checks and optimizations.

#### Dynamically typed code calls statically typed code

```ruby
Foo = Typeclass.new s: Object do
  fn :foo, [:s]
end

Typeclass.instance Foo, s: String do
  def foo(s)
    s + s.reverse
  end
end

Typeclass.instance Foo, s: Symbol do
  def foo(s)
    (s.to_s + s.to_s.reverse).to_sym
  end
end

Foo.foo 'abc' #=> "abccba"
Foo.foo :abc #=> :abccba
```

In the last two lines the function is called with arguments of two different
types, so we have to choose the right typeclass' instance at runtime.
This operation has a huge runtime overhead which can not be avoided.

But there is a solution. Sometimes the right instance can be definitely
determined by the type of the first argument of a function. In this case
the function can be turned into method of it's first argument.
This is called infix function, and will be described in future versions
of this document.

#### Statically typed code calls statically typed code

This is the most convenient option for optimizations. Presumably the code
will be close to the machine code in execution speed and memory consumption.

### Additional optimization possibilities

The previously described model has great ability to optimize business logic
only. This is absolutely pointless.

The gem aims to allow to effectively "crunch numbers" in Ruby, what means
strongly optimized arithmetic. The main problem is that Ruby's standard
library is written in Ruby and C, so we can not analyze it's code at runtime.

Nevertheless, it is a small problem. The Ruby's standard library is well-known.
We can assume it's properties. This should be enough for optimizations
of arithmetics (the result of `2 + 2` is evident). The Ruby's ability of
monkey-patching (when method `Integer#*` is redefined to return something other
than result of integer multiplication, for example) can be ignored because this
is a terrible practice.
