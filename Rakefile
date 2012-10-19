require 'rake'

# These tasks help build and release the gem
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.pattern ='spec/**/*_spec.rb'
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--format progress}
end

desc "Run all tests for CI"
task "ci" => ["spec", "cucumber"]

task "default" => "ci"
