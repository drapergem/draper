source :rubygems

gemspec

platforms :ruby do
  gem "sqlite3"
end

platforms :jruby do
  gem "minitest", ">= 3.0"
  gem "activerecord-jdbcsqlite3-adapter"
end

case ENV["RAILS_VERSION"]
when "master"
  gem "rails", github: "rails/rails"
  gem "mongoid", github: "mongoid/mongoid", branch: "4.0.0-dev"

when "3.2", nil
  gem "rails", "~> 3.2.0"
  gem "mongoid", "~> 3.0.0"

when "3.1"
  gem "rails", "~> 3.1.0"
  gem "mongoid", "~> 3.0.0"

when "3.0"
  gem "rails", "~> 3.0.0"
end
