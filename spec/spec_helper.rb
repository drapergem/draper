require 'rubygems'
require 'bundler'
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