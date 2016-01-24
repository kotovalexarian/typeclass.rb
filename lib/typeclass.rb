require 'typeclass/version'
require 'typeclass/function'
require 'typeclass/instance'
require 'typeclass/superclass'

##
# Haskell type classes in Ruby.
#
class Typeclass < Module
  include Superclass::TypeclassMixin

  extend Instance::TypeclassMixin::ClassMethods
  include Instance::TypeclassMixin

  # @!attribute [r] constraints
  # @return [Hash] Type parameter constraints.
  # @api private
  attr_reader :constraints

  # Create new typeclass.
  #
  # @example
  #   Foo = Typeclass.new a: Object do
  #   end
  #
  # @param constraints [Hash] Type parameter constraints.
  # @yield Opens type class as module.
  #
  # @note
  #   Exceptions raised by this method should stay unhandled.
  #
  def initialize(constraints, &block)
    fail LocalJumpError, 'no block given' unless block_given?

    Typeclass.check_constraints! constraints

    @constraints = constraints

    instance_exec(&block)
  end

  # Check if object is type.
  #
  # @see TYPES
  #
  # @param object [Object] Any Ruby object.
  # @return [Boolean] Is `object` a type.
  #
  # @api private
  #
  def self.type?(object)
    TYPES.any? { |type| object.is_a? type }
  end

  # Check if type parameter constraints have valid format.
  # Raise exceptions if format is invalid.
  #
  # @param constraints [Hash] Type parameter constraints.
  # @return [void]
  #
  # @raise [TypeError, ArgumentError]
  #
  # @api private
  #
  def self.check_constraints!(constraints)
    fail TypeError unless constraints.is_a? Hash
    fail ArgumentError if constraints.empty?

    constraints.each do |name, type|
      name.is_a? Symbol or
        fail TypeError, 'parameter name is not a Symbol'
      fail TypeError unless Typeclass.type? type
    end
  end

private

  # Available constraint types.
  # @see type?
  TYPES = [Class, Module].freeze

  # Type used for no constraint.
  # @see Typeclass::Instance::Params.check_raw_params!
  BASE_CLASS = Object

  # Declare function signature with optional default block.
  #
  # @example
  #   Foo = Typeclass.new a: Enumerable do
  #     fn :no_default, [:a]
  #     fn :with_default, [:a] do |a|
  #       a.first
  #     end
  #   end
  #
  #   Foo.instance a: Array do end
  #
  #   Foo.with_default ['a', 'b', 'c'] #=> "a"
  #   Foo.no_defalt ['a', 'b', 'c']    # raises `NoMethodError`
  #
  # @param name [Symbol, String] Function name.
  # @param sig [Array<Symbol>] Function signature.
  # @yield Optional default block.
  #
  # @note
  #   Exceptions raised by this method should stay unhandled.
  #
  def fn(name, sig, &block)
    name = name.to_sym rescue (raise NameError)
    fail NameError if method_defined? name
    fail TypeError unless sig.is_a? Array
    fail TypeError unless sig.all? { |item| item.is_a? Symbol }

    p = Function.new(self, name, sig, &block).to_proc

    define_singleton_method name, &p
    define_method name, &p
  end
end
