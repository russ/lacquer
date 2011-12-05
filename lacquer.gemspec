# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lacquer/version"

Gem::Specification.new do |s|
  s.name = "lacquer"
  s.version = Lacquer::VERSION
  s.authors = ["Russ Smith (russ@bashme.org)", "Ryan Johns", "Garry Tan (garry@posterous.com), Gabe da Silveira (gabe@websaviour.com)", "H\u{e5}kon Lerring"]
  s.email = "russ@bashme.org"
  s.homepage = "http://github.com/russ/lacquer"
  s.summary = "Rails drop in for Varnish support."
  s.description = "Rails drop in for Varnish support."
  s.rubyforge_project = "lacquer"
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency('activesupport', '>= 2.3.10')
  s.add_dependency('i18n', '~> 0.4')
  s.add_dependency('erubis')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 2.5')
  s.add_development_dependency('yard')
end
