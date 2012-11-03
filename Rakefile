require 'rake'

# These tasks help build and release the gem
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new

file "spec/dummy/db/test.sqlite3" do
  system "cd spec/dummy && 
          RAILS_ENV=test rake db:migrate"
end

task :cucumber => :"spec/dummy/db/test.sqlite3"

desc "Run all tests for CI"
task "ci" => ["spec", "cucumber"]

task "default" => "ci"
