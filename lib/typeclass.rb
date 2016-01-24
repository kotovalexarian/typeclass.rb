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
  #   Foo = Typeclass.new :a do
  #   end
  #
  #   Bar = Typeclass.new a: Numeric do
  #   end
  #
  # @yield Opens type class as module.
  #
  # @note
  #   Exceptions raised by this method should stay unhandled.
  #
  def initialize(*args, &block)
    fail LocalJumpError, 'no block given' unless block_given?

    keys = args.dup
    options = keys.pop if args.last.is_a? Hash

    @constraints = Typeclass.args_to_constraints! keys, options || {}

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

  # @param args [Array<Symbol>]
  # @param options [Hash<Symbol, type>]
  # @return [Hash<Symbol, type>]
  #
  # @raise [TypeError, ArgumentError]
  #
  # @api private
  #
  def self.args_to_constraints!(keys, options)
    fail ArgumentError if keys.empty?
    fail TypeError unless keys.all? { |key| key.is_a? Symbol }

    options.each do |key, type|
      fail ArgumentError unless keys.include? key
      fail TypeError unless type? type
    end

    keys.map do |arg|
      { arg => BASE_CLASS }
    end.inject(&:merge).merge options
  end
end
