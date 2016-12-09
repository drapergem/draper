require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task "default" => "ci"

desc "Run all tests for CI"
task "ci" => "spec"

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec)
