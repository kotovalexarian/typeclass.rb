# TODO: refactoring
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity

require 'typeclass/version'
require 'typeclass/instance'

##
# Haskell type classes in Ruby.
#
class Typeclass < Module
  attr_reader :constraints, :instances

  TYPES = [Class, Module]
  BASE_CLASS = Object

  def initialize(constraints, &block)
    fail LocalJumpError, 'no block given' unless block_given?

    Typeclass.check_constraints! constraints

    @constraints = constraints
    @instances = []

    instance_exec(&block)
  end

  def fn(name, sig, &block)
    name = name.to_sym rescue (raise NameError)
    fail NameError if method_defined? name
    fail TypeError unless sig.is_a? Array
    fail TypeError unless sig.all? { |item| item.is_a? Symbol }

    typeclass = self

    f = lambda do |*args|
      fail ArgumentError if sig.length != args.count

      instance = typeclass.instance sig, args

      fail NotImplementedError unless instance

      if instance.implements? name
        instance.transmit name, *args
      elsif block
        block.call(*args)
      else
        fail NoMethodError
      end
    end

    begin
      define_singleton_method name, &f
      define_method name, &f
    rescue
      raise NameError
    end
  end

  def instance(sig, args)
    instances.each do |instance|
      return instance if instance.matched_by? sig, args
    end

    nil
  end

  def self.instance(typeclass, raw_params, &block)
    fail LocalJumpError, 'no block given' unless block_given?
    fail TypeError unless typeclass.is_a? Typeclass

    Instance::Params.check_raw_params! raw_params, typeclass.constraints

    params = Instance::Params.new(raw_params)
    index = get_index(typeclass, params)

    hidden_module = Instance::HiddenModule.new(typeclass, &block)

    instance = Instance.new(params, hidden_module)
    typeclass.instances.insert index, instance

    instance
  end

  def self.type?(object)
    TYPES.any? { |type| object.is_a? type }
  end

  def self.get_index(typeclass, new_params)
    index = nil

    (0..typeclass.instances.count).each do |i|
      instance = typeclass.instances[i]

      if instance.nil?
        index = i if index.nil?
        break
      end

      current_params = instance.params

      fail TypeError if current_params.collision? new_params

      if index.nil? && current_params > new_params
        index = i
        break
      end
    end

    index
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
