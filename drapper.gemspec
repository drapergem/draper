# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "drapper/version"

Gem::Specification.new do |s|
  s.name        = "drapper"
  s.version     = Drapper::VERSION
  s.authors     = ["Jeff Casimir"]
  s.email       = ["jeff@casimircreative.com"]
  s.homepage    = "http://github.com/esdras/draper"
  s.summary     = "Decorator pattern implmentation for Rails. Just using this gem temporarily until my code is merged into Jeff's gem or he gets the view_context bug fixed"
  s.description = "Draper reimagines the role of helpers in the view layer of a Rails application, allowing an object-oriented approach rather than procedural."

  s.rubyforge_project = "draper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
