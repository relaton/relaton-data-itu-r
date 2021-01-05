# -*- encoding: utf-8 -*-
# stub: relaton-itu 1.7.3 ruby lib

Gem::Specification.new do |s|
  s.name = "relaton-itu".freeze
  s.version = "1.7.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ribose Inc.".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-01-04"
  s.description = "RelatonItu: retrieve ITU Standards for bibliographic use using the BibliographicItem model".freeze
  s.email = ["open.source@ribose.com".freeze]
  s.homepage = "https://github.com/metanorma/relaton-itu".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "2.6.14.4".freeze
  s.summary = "RelatonItu: retrieve ITU Standards for bibliographic use using the BibliographicItem model".freeze

  s.installed_by_version = "2.6.14.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<debase>.freeze, [">= 0"])
      s.add_development_dependency(%q<equivalent-xml>.freeze, ["~> 0.6"])
      s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<ruby-debug-ide>.freeze, [">= 0"])
      s.add_development_dependency(%q<ruby-jing>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<vcr>.freeze, ["~> 5.0.0"])
      s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<relaton-bib>.freeze, ["~> 1.7.0"])
    else
      s.add_dependency(%q<debase>.freeze, [">= 0"])
      s.add_dependency(%q<equivalent-xml>.freeze, ["~> 0.6"])
      s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<ruby-debug-ide>.freeze, [">= 0"])
      s.add_dependency(%q<ruby-jing>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<vcr>.freeze, ["~> 5.0.0"])
      s.add_dependency(%q<webmock>.freeze, [">= 0"])
      s.add_dependency(%q<relaton-bib>.freeze, ["~> 1.7.0"])
    end
  else
    s.add_dependency(%q<debase>.freeze, [">= 0"])
    s.add_dependency(%q<equivalent-xml>.freeze, ["~> 0.6"])
    s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<ruby-debug-ide>.freeze, [">= 0"])
    s.add_dependency(%q<ruby-jing>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<vcr>.freeze, ["~> 5.0.0"])
    s.add_dependency(%q<webmock>.freeze, [">= 0"])
    s.add_dependency(%q<relaton-bib>.freeze, ["~> 1.7.0"])
  end
end
