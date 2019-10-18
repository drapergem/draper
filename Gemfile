source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

platforms :ruby do
  gem 'sqlite3', '~> 1.4'
end

platforms :jruby do
  gem 'minitest'
  gem 'activerecord-jdbcsqlite3-adapter'
end

gem 'rails', '~> 5.0'
gem 'mongoid', github: 'mongodb/mongoid'
