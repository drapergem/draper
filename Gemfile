source "https://rubygems.org"

gemspec

gem 'puma'

platforms :ruby do
  if RUBY_VERSION >= "2.5.0"
    gem 'sqlite3'
  else
    gem 'sqlite3', '~> 1.3.6'
  end
end

platforms :jruby do
  gem "minitest"
  gem "activerecord-jdbcsqlite3-adapter"
end

case rails_version = ENV['RAILS_VERSION']
when nil
  gem 'rails'
when 'edge'
  gem 'rails', github: 'rails/rails'
else
  gem 'rails', "~> #{rails_version}.0"
end

gem 'mongoid' unless
    rails_version == 'edge'
gem 'active_model_serializers'

case RUBY_VERSION
when '2.6'...'3.0'
  gem "turbo-rails", "<= 2.0.7"
  gem "redis", "~> 4.0"
when '3.0'...'4'
  gem 'turbo-rails'
  gem 'redis', '~> 4.0'
end

if RUBY_VERSION < "2.5.0"
  gem 'rspec-activerecord-expectations', '~> 1.2.0'
  gem 'simplecov', '0.17.1'
  gem "loofah", "< 2.21.0" # Workaround for `uninitialized constant Nokogiri::HTML4`
end
