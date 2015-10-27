require 'bundler/gem_tasks'

task default: [:lint]

task lint: [:rubocop]

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'yard'
YARD::Rake::YardocTask.new
