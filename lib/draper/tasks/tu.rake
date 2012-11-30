if Rake::Task.task_defined?('test:run')
  Rake::Task['test:run'].enhance do
    Rake::Task['test:decorators'].invoke
  end
end
