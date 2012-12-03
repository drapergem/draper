require "rake/testtask"

klass = nil

if Rails.version[0,3] == "3.0"
  require 'rails/test_unit/railtie'
  klass = Rake::TestTask
else 
  require "rails/test_unit/sub_test_task"
  klass = Rails::SubTestTask
end

namespace :test do
  klass.new(:decorators => "test:prepare") do |t|
    t.libs << "test"
    t.pattern = "test/decorators/**/*_test.rb"
  end
end
