require 'rubygems'
require 'bundler'
Bundler.require
require 'active_support'
require 'action_view'
require 'bundler/setup'
require 'draper'

Dir["spec/support/**/*.rb"].each do |file|
  require "./" + file
end

RSpec.configure do |config|

end