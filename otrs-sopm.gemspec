# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
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

  spec.add_runtime_dependency 'nokogiri'

  spec.required_ruby_version = '>= 3.0'
  spec.add_development_dependency 'bundler', '> 2.0'
  spec.add_development_dependency 'minitest', '>= 4.7.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'rubocop-rake'
end
