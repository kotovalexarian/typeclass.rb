# This should be on the top of the file
require 'simplecov'

require 'minitest/autorun'

require 'typeclass'

def deftest(name, &block)
  name = ('test_' + name.to_s).to_sym
  define_method(name, &block)
end
