Rake::Task["test:run"].enhance do
  Rake::Task["test:decorators"].invoke
end
