require 'rubygems'

gemspec = Gem::Specification.load('typeclass.gemspec')

github_user, github_project =
  gemspec.homepage.scan(%r{^https://github\.com/([^/]+)/([^/]+)/?$})[0]

require 'bundler/gem_tasks'

task default: [:tests, :lint]

task tests: ['examples:test', :test]

require 'rake/testtask'
Rake::TestTask.new('examples:test') do |t|
  t.pattern = 'examples/*.rb'
end

Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
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

desc 'Render examples to README'
task :examples do
  EXAMPLES_DIR = 'examples'
  README = 'README.md'
  SUBTITLE = 'Examples'
  EXPR = "#{SUBTITLE}\n#{'-' * SUBTITLE.length}\n"
  REGEXP = /#{EXPR}/

  examples = Dir["#{EXAMPLES_DIR}/*"].each_with_index.map do |filename, index|
    example = File.read filename

    <<-END
#{"-----\n\n" unless index.zero?}File [#{filename}](#{filename}):

```ruby
#{example}```
END
  end.join("\n")

  input = File.read README
  pos = input =~ REGEXP
  output = "#{input[0...pos]}#{EXPR}\n#{examples}"
  File.write README, output
end
