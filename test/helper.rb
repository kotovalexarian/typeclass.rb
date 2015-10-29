# This should be on the top of the file
require 'simplecov'

# rubocop:disable Lint/HandleExceptions

require 'minitest/autorun'

require 'typeclass'

def should_raise(exception)
  fail 'no block given' unless block_given?

  begin
    yield
  rescue exception
  rescue
    raise
  else
    fail
  end
end

def deftest(name, &block)
  name = ('test_' + name.to_s).to_sym
  define_method(name, &block)
end
