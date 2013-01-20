require 'rake/testtask'
require 'rspec/core/rake_task'

Rake::Task[:test].clear
Rake::TestTask.new :test do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

RSpec::Core::RakeTask.new :spec

RSpec::Core::RakeTask.new :fast_spec do |t|
  t.pattern = "fast_spec/**/*_spec.rb"
end

task :default => [:test, :spec, :fast_spec]
