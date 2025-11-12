source "https://rubygems.org"

gemspec

gem 'puma'

platforms :ruby do
  if RUBY_VERSION >= "3.0.0"
    gem 'sqlite3'
  elsif RUBY_VERSION >= "2.5.0"
    gem 'sqlite3', '~> 1.4.0'
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

# FIXME: Remove the later condition after `mongoid` supports Rails 8.1
gem 'mongoid' unless
  rails_version == 'edge' || rails_version == '8.1'
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

if RUBY_VERSION < "3.0.0"
  gem "concurrent-ruby", "< 1.3.5"
end

# FIXME: Use releases gems after they support Rails 8.1
if rails_version.to_s >= '8.1'
  gem 'mongoid', github: 'mongodb/mongoid', ref: 'eac49f0'
end
