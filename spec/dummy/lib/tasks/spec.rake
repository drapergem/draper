require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task "default" => "spec"
