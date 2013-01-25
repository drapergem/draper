source :rubygems

gemspec

platforms :ruby do
  gem "sqlite3"
end

platforms :jruby do
  gem "minitest", ">= 3.0"
  gem "activerecord-jdbcsqlite3-adapter"
end

version = ENV["RAILS_VERSION"] || "3.2"

rails = case version
when "master"
  {github: "rails/rails"}
else
  "~> #{version}.0"
end

mongoid = case version
when "master"
  {github: "mongoid/mongoid", branch: "4.0.0-dev"}
when "3.1", "3.2"
  "~> 3.0.0"
end

devise = case version
when "3.1", "3.2"
  "~> 2.2"
end

gem "rails", rails
gem "mongoid", mongoid if mongoid
gem "devise", devise if devise
