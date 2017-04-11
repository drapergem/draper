require File.join(__dir__, "lib", "draper", "version")

Gem::Specification.new do |s|
  s.name        = "draper"
  s.version     = Draper::VERSION
  s.authors     = ["Jeff Casimir", "Steve Klabnik"]
  s.email       = ["jeff@casimircreative.com", "steve@steveklabnik.com"]
  s.homepage    = "http://github.com/drapergem/draper"
  s.summary     = "View Models for Rails"
  s.description = "Draper adds an object-oriented layer of presentation logic to your Rails apps."
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.2.2'

  s.add_dependency 'activesupport', '~> 5.0'
  s.add_dependency 'actionpack', '~> 5.0'
  s.add_dependency 'request_store', '~> 1.0'
  s.add_dependency 'activemodel', '~> 5.0'
  s.add_dependency 'activemodel-serializers-xml', '~> 1.0'

  s.add_development_dependency 'ammeter'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'minitest-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'active_model_serializers', '~> 0.10'
  s.add_development_dependency 'rubocop'
end
