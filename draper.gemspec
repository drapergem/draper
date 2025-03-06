require_relative 'lib/draper/version'

Gem::Specification.new do |s|
  s.name        = "draper"
  s.version     = Draper::VERSION
  s.authors     = ["Jeff Casimir", "Steve Klabnik"]
  s.email       = ["jeff@casimircreative.com", "steve@steveklabnik.com"]
  s.homepage    = "https://github.com/drapergem/draper"
  s.summary     = "View Models for Rails"
  s.description = "Draper adds an object-oriented layer of presentation logic to your Rails apps."
  s.license     = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  s.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.2.2'

  s.add_dependency 'activesupport', '>= 5.0'
  s.add_dependency 'actionpack', '>= 5.0'
  s.add_dependency 'request_store', '>= 1.0'
  s.add_dependency 'activemodel', '>= 5.0'
  s.add_dependency 'activemodel-serializers-xml', '>= 1.0'
  s.add_dependency 'ruby2_keywords'

  s.add_development_dependency 'ammeter'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-activerecord-expectations'
  s.add_development_dependency 'minitest-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
end
