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

  include Function::TypeclassMixin

  # Available constraint types.
  # @see type?
  TYPES = [Class, Module].freeze

  # Type used for no constraint.
  # @see Typeclass::Instance::Params.check_raw_params!
  BASE_CLASS = Object

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
  # @param type_vars [Array<Symbol>] Type variables.
  # @param options [Hash] Type variable constraints.
  # @yield Opens type class as module.
  #
  # @note
  #   Exceptions raised by this method should stay unhandled.
  #
  def initialize(*args, &block)
    fail LocalJumpError, 'no block given' unless block_given?

    options = args.pop if args.last.is_a? Hash
    options ||= {}

    fail ArgumentError if args.empty?
    fail TypeError unless args.all? { |arg| arg.is_a? Symbol }
    fail ArgumentError unless options.keys.all? { |key| args.include? key }

    constraints = args.map do |arg|
      { arg => BASE_CLASS }
    end.inject(&:merge).merge options

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
end
