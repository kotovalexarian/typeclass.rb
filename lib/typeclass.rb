require 'typeclass/version'
require 'typeclass/function'
require 'typeclass/instance'
require 'typeclass/superclass'

##
# Haskell type classes in Ruby.
#
class Typeclass < Module
  include Superclass::TypeclassMixin

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
  def initialize(*superclasses, constraints, &block)
    fail LocalJumpError, 'no block given' unless block_given?

    Superclass.check! superclasses
    Typeclass.check_constraints! constraints
    Typeclass.check_superclass_args! constraints, superclasses

    @superclasses = superclasses
    @constraints = constraints
    @instances = []

    instance_exec(&block)
  end

  # Create new instance of type class.
  #
  # @example
  #   Formatter = Typeclass.new a: Object do
  #     fn :format, [:a]
  #   end
  #
  #   Formatter.instance a: Integer do
  #     def format(a)
  #       "exactly #{a}"
  #     end
  #   end
  #
  #   Formatter.instance a: Float do
  #     def format(a)
  #       "about #{a.round 2}"
  #     end
  #   end
  #
  # @param raw_params [Hash] Type parameters.
  # @yield Opens module for function implementations.
  # @return [Typeclass::Instance] New instance of type class.
  #
  # @note
  #   Exceptions raised by this method should stay unhandled.
  #
  def instance(raw_params, &block)
    fail LocalJumpError, 'no block given' unless block_given?

    Instance::Params.check_raw_params! raw_params, constraints

    fail NotImplementedError unless superclasses.all? do |superclass|
      superclass.implemented? raw_params
    end

    params = Instance::Params.new(raw_params)
    index = get_index! params

    hidden_module = Instance::HiddenModule.new(self, &block)

    instance = Instance.new(params, hidden_module)
    instances.insert index, instance

    instance
  end

  # Create new instance of type class.
  #
  # @see #instance
  #
  # @param typeclass [Typeclass] Type class.
  # @param raw_params [Hash] Type parameters.
  # @yield Opens module for function implementations.
  # @return [Typeclass::Instance] New instance of type class.
  #
  # @note
  #   Exceptions raised by this method should stay unhandled.
  #
  def self.instance(typeclass, raw_params, &block)
    fail TypeError unless typeclass.is_a? Typeclass

    typeclass.instance raw_params, &block
  end

  # Get type class instance for function with signature `sig`
  # when it was called with arguments `args`.
  #
  # @param sig [Array<Symbol>] Function signature.
  # @param args [Array] Function arguments.
  # @return [Typeclass::Instance, nil] Type class instance if match found.
  #
  # @api private
  #
  def get_instance(sig, args)
    instances.each do |instance|
      return instance if instance.matched_by? sig, args
    end

    nil
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

  # Check is type parameter constraints have valid format.
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

  def self.check_superclass_args!(constraints, superclasses)
    fail ArgumentError unless superclasses.all? do |superclass|
      superclass.args.all? { |arg| constraints.key? arg }
    end
  end

private

  # Available constraint types.
  # @see type?
  TYPES = [Class, Module].freeze

  # Type used for no constraint.
  # @see Typeclass::Instance::Params.check_raw_params!
  BASE_CLASS = Object

  # @!attribute [r] superclasses
  # @return [Array<Typeclass::Superclass>] Type class superclasses.
  attr_reader :superclasses

  # @!attribute [r] constraints
  # @return [Hash] Type parameter constraints.
  attr_reader :constraints

  # @!attribute [r] instances
  # @return [Array<Typeclass::Instance>] Type class instances.
  attr_reader :instances

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

  # Get index for new instance in array of instances.
  #
  # @param params [Typeclass::Params] Type parameters.
  # @return [Integer] Index for new instance in array of instances.
  #
  # @raise [TypeError] Collision with existing instance.
  #
  def get_index!(params)
    (0..instances.count).each do |i|
      instance = instances[i]
      return i if instance.nil?
      fail TypeError if instance.params.collision? params
      return i if instance.params > params
    end
  end
end
