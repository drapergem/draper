require 'rake/testtask'

rails_version = Rails.version.to_f
test_task = if rails_version < 3.2 || rails_version > 4.2
  require 'rails/test_unit/railtie'
  Rake::TestTask
else
  require 'rails/test_unit/sub_test_task'
  Rails::SubTestTask
end

namespace :test do
  test_task.new(:decorators => "test:prepare") do |t|
    t.libs << "test"
    t.pattern = "test/decorators/**/*_test.rb"
  end
end

if Rails.version.to_f < 4.2 && Rake::Task.task_defined?('test:run')
  Rake::Task['test:run'].enhance do
    Rake::Task['test:decorators'].invoke
  end
end
