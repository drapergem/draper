ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

RSpec.configure do |config|
  config.expect_with(:rspec) {|c| c.syntax = :expect}
  config.order = :random
  if defined?(Mongoid)
    config.before(:each) do
      Mongoid.truncate!
    end
  end
end
