
def run_in_dummy_app(command)
  success = system("cd spec/dummy && #{command}")
  raise "#{command} failed" unless success
end

def reset_dummy_db
  run_in_dummy_app "rm -f db/*.sqlite3"
  run_in_dummy_app "RAILS_ENV=development rake db:schema:load db:seed"
  run_in_dummy_app "RAILS_ENV=production rake db:schema:load db:seed"
  run_in_dummy_app "RAILS_ENV=test rake db:environment:set db:schema:load"
end

