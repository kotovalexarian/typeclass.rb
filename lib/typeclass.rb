require 'typeclass/version'
require 'typeclass/function'
require 'typeclass/instance'

##
# Haskell type classes in Ruby.
#
class Typeclass < Module
  def initialize(constraints, &block)
    fail LocalJumpError, 'no block given' unless block_given?

    Typeclass.check_constraints! constraints

    @constraints = constraints
    @instances = []

    instance_exec(&block)
  end

  def instance(raw_params, &block)
    fail LocalJumpError, 'no block given' unless block_given?

    Instance::Params.check_raw_params! raw_params, constraints

    params = Instance::Params.new(raw_params)
    index = get_index! params

    hidden_module = Instance::HiddenModule.new(self, &block)

    instance = Instance.new(params, hidden_module)
    instances.insert index, instance

    instance
  end

  def get_instance(sig, args)
    instances.each do |instance|
      return instance if instance.matched_by? sig, args
    end

    nil
  end

private

  TYPES = [Class, Module]
  BASE_CLASS = Object

  attr_reader :constraints, :instances

  def fn(name, sig, &block)
    name = name.to_sym rescue (raise NameError)
    fail NameError if method_defined? name
    fail TypeError unless sig.is_a? Array
    fail TypeError unless sig.all? { |item| item.is_a? Symbol }

    p = Function.new(self, name, sig, &block).to_proc

    define_singleton_method name, &p
    define_method name, &p
  end

  def get_index!(params)
    (0..instances.count).each do |i|
      instance = instances[i]
      return i if instance.nil?
      fail TypeError if instance.params.collision? params
      return i if instance.params > params
    end
  end

  def self.instance(typeclass, raw_params, &block)
    fail TypeError unless typeclass.is_a? Typeclass

    typeclass.instance raw_params, &block
  end

  def self.type?(object)
    TYPES.any? { |type| object.is_a? type }
  end

  def self.check_constraints!(constraints)
    fail TypeError unless constraints.is_a? Hash
    fail ArgumentError if constraints.empty?

    constraints.each do |name, type|
      name.is_a? Symbol or
        fail TypeError, 'parameter name is not a Symbol'
      fail TypeError unless Typeclass.type? type
    end
  end
end
