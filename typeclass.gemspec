# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'typeclass/version'

Gem::Specification.new do |spec|
  spec.name          = 'typeclass'
  spec.version       = Typeclass::VERSION
  spec.authors       = ['Braiden Vasco']
  spec.email         = ['braiden-vasco@users.noreply.github.com']

  spec.summary       = 'Haskell type classes in Ruby'
  spec.description   = 'Haskell type classes in Ruby.'
  spec.homepage      = 'https://github.com/braiden-vasco/typeclass.rb'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.34'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'redcarpet', '~> 3.3'
  spec.add_development_dependency 'github_changelog_generator', '~> 1.9'
end
