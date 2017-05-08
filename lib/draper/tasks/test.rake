require 'rake/testtask'
require 'rails/test_unit/railtie'

namespace :test do
  Rake::TestTask.new(decorators: "test:prepare") do |t|
    t.libs << "test"
    t.pattern = "test/decorators/**/*_test.rb"
  end
end
