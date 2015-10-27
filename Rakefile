require 'rubygems'

gemspec = Gem::Specification.load('typeclass.gemspec')

github_user, github_project =
  gemspec.homepage.scan(%r{^https://github\.com/([^/]+)/([^/]+)/?$})[0]

require 'bundler/gem_tasks'

task default: [:lint]

task lint: [:rubocop]

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'yard'
YARD::Rake::YardocTask.new

require 'github_changelog_generator/task'
GitHubChangelogGenerator::RakeTask.new do |config|
  config.user = github_user
  config.project = github_project
end
