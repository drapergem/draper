require 'rspec/core/rake_task'
require 'rake/testtask'

RSpec::Core::RakeTask.new :rspec

Rake::TestTask.new :mini_test do |t|
  t.test_files = ["mini_test/mini_test_integration_test.rb"]
end

task :default => [:rspec, :mini_test]
