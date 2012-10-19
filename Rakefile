require 'rake'

# These tasks help build and release the gem
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new

desc "Run all tests for CI"
task "ci" => ["spec", "cucumber"]

task "default" => "ci"
