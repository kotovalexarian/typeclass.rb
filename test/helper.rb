# rubocop:disable Lint/HandleExceptions

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
