# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name    = 'closing_comments'
  spec.version = '0.1'

  spec.author      = 'Marcin Wyszynski'
  spec.summary     = 'Helper to add closing comments to Ruby entities'
  spec.description = spec.summary
  spec.homepage    = 'https://github.com/marcinwyszynski/closing_comments'
  spec.license     = 'MIT'

  spec.files      = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']
  spec.test_files = spec.files.grep(/^spec/)

  spec.add_dependency 'parser', '~> 2.4'
  spec.add_development_dependency 'bundler', '~> 1.14', '>= 1.14.6'
  spec.add_development_dependency 'rake', '~> 12.0'
end # Gem::Specification
