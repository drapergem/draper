require 'rspec/core/rake_task'
require 'rake/testtask'

RSpec::Core::RakeTask.new :rspec

RSpec::Core::RakeTask.new :fast_spec do |t|
  t.pattern = "fast_spec/**/*_spec.rb"
end

Rake::TestTask.new :mini_test do |t|
  t.test_files = ["mini_test/mini_test_integration_test.rb"]
end

task :default => [:rspec, :mini_test, :fast_spec]
