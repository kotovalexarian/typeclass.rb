require 'rubygems'

gemspec = Gem::Specification.load('typeclass.gemspec')

github_user, github_project =
  gemspec.homepage.scan(%r{^https://github\.com/([^/]+)/([^/]+)/?$})[0]

require 'bundler/gem_tasks'

task default: [:test, :lint]

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.test_files = FileList['test/*.rb', 'examples/*.rb']
  t.libs += %w(lib test)
  t.warning = true
  t.verbose = true
end

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
