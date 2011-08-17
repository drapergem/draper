require 'rubygems'
require 'bundler'

require 'rspec'
begin
  require 'cover_me'
rescue LoadError
  # Silently fail
end
require './spec/samples/application_helper.rb'
Bundler.require
Dir.glob('./spec/samples/*') {|file| require file}
require 'active_support'
require 'action_view'
require 'bundler/setup'

require 'draper'

Dir["spec/support/**/*.rb"].each do |file|
  require "./" + file
end

RSpec.configure do |config|

end