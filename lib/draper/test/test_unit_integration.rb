require "rake/testtask"
require "rails/test_unit/sub_test_task"

namespace :test do
  Rails::SubTestTask.new(:decorators => "test:prepare") do |t|
    t.libs << "test"
    t.pattern = "test/decorators/**/*_test.rb"
  end
end
