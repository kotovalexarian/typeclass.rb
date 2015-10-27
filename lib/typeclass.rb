# rubocop:disable Metrics/MethodLength

require 'typeclass/version'

##
# Haskell type classes in Ruby.
#
class Typeclass < Module
  TYPES = [Class, Module]

  def initialize(params, &block)
    fail LocalJumpError, 'no block given' unless block_given?
    fail TypeError unless params.is_a? Hash
    fail ArgumentError if params.empty?

    @params = params.each do |name, type|
      name.is_a? Symbol or
        fail TypeError, 'parameter name is not a Symbol'
      fail TypeError unless Typeclass.type? type
    end

    instance_exec(&block)
  end

  def fn(name, sig)
    name = name.to_sym rescue (raise NameError)
    fail NameError if method_defined? name
    fail TypeError unless sig.is_a? Array
    fail TypeError unless sig.all? { |item| item.is_a? Symbol }

    f = -> {}

    begin
      define_singleton_method name, &f
      define_method name, &f
    rescue
      raise NameError
    end
  end

  def self.type?(object)
    TYPES.any? { |type| object.is_a? type }
  end
end
