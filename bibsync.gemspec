# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/lib/bibsync/version'
require 'date'

Gem::Specification.new do |s|
  s.name              = 'bibsync'
  s.version           = BibSync::VERSION
  s.date              = Date.today.to_s
  s.authors           = ['Daniel Mendler']
  s.email             = ['mail@daniel-mendler.de']
  s.summary           = 'BibSync is a tool to synchronize scientific papers and BibTeX bibliography files'
  s.description       = 'BibSync is a tool to synchronize scientific papers and BibTeX bibliography files'
  s.homepage          = 'https://github.com/minad/bibsync'
  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_runtime_dependency('multi_xml')
  s.add_runtime_dependency('faraday')
  s.add_runtime_dependency('faraday_middleware')
  s.add_development_dependency('rake')
  s.add_development_dependency('minitest')
end
