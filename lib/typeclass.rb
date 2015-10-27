require 'typeclass/version'

##
# Haskell type classes in Ruby.
#
class Typeclass < Module
  TYPES = [Class, Module]

  def initialize(params)
    fail LocalJumpError, 'no block given' unless block_given?
    fail TypeError unless params.is_a? Hash
    fail ArgumentError if params.empty?

    @params = params.each do |name, type|
      name.is_a? Symbol or
        fail TypeError, 'parameter name is not a Symbol'
      fail TypeError unless Typeclass.type? type
    end
  end

  def self.type?(object)
    TYPES.any? { |type| object.is_a? type }
  end
end
