require 'rake'

# These tasks help build and release the gem
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new

namespace :db do
  desc 'Prepare sqlite database'
  task :migrate do
    system 'cd spec/dummy && rake db:migrate RAILS_ENV=test && rake db:migrate RAILS_ENV=development'
  end
end

desc "Run all tests for CI"
task "ci" => ["spec", "cucumber"]

task "default" => "ci"
