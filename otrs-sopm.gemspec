# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'otrs/sopm/version'

Gem::Specification.new do |spec|
  spec.name          = 'otrs-sopm'
  spec.version       = OTRS::SOPM::VERSION
  spec.authors       = ['Thorsten Eckel']
  spec.email         = ['thorsten.eckel@znuny.com']

  spec.summary       = 'This gem provides a class to parse, manipulate and store SOPM files and create OPM strings from them.'
  spec.homepage      = 'https://github.com/znuny/otrs-sopm'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'nokogiri', '~> 0'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0'
end
