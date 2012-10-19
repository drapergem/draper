require 'bundler/gem_tasks'
require 'rake'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RCOV = RUBY_VERSION.to_f == 1.8

namespace :spec do

  RSpec::Core::RakeTask.new(:coverage) do |t|
    t.pattern = 'spec/**/*_spec.rb'

    if RCOV
      t.rcov = true
      t.rcov_opts = '--exclude osx\/objc,spec,gems\/'
    end
  end

  RSpec::Core::RakeTask.new(:normal) do |t|
    t.pattern ='spec/**/*_spec.rb'
    t.rcov = false
  end

  namespace :coverage do
    desc "Cleanup coverage data"
    task :cleanup do
      rm_rf 'coverage.data'
      rm_rf 'coverage'
    end

    desc "Browse the code coverage report."
    task :report => ["spec:coverage:cleanup", "spec:coverage"] do
      if RCOV
        require "launchy"
        Launchy.open("coverage/index.html")
      else
        require 'cover_me'
        CoverMe.complete!
      end
    end
  end

end

namespace :cucumber do
  Cucumber::Rake::Task.new(:ci) do |t|
    t.cucumber_opts = %w{--format progress}
  end
end

desc "Run Cucumber features"
task "cucumber" => "cucumber:ci"

desc "RSpec tests"
task "spec" => "spec:normal"

desc "Run all tests for CI"
task "ci" => ["spec:normal", "cucumber:ci"]

task "default" => "ci"
