# frozen_string_literal: true

require_relative 'lib/edit_in_place/version'

Gem::Specification.new do |spec|
  spec.name        = 'edit_in_place'
  spec.version     = EditInPlace::VERSION
  spec.authors     = ['Jacob']
  spec.email       = ['jacoblockard99@gmail.com']
  spec.summary     = 'A Rails plugin that facilitates the creation of intuitive editable content.'
  spec.description = <<~DESC
    edit_in_place is a Ruby on Rails plugin that allows the creation of user interfaces that allow the user to edit content in an intuitive, natural, "in place" way.
  DESC
  spec.homepage = 'https://github.com/jacoblockard99/edit_in_place'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_development_dependency 'byebug', '~> 11.0'
  spec.add_development_dependency 'rspec-rails', '~> 5.0'
  spec.add_development_dependency 'rubocop', '~> 1.18'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.4'
  spec.add_development_dependency 'simplecov', '0.17'

  spec.add_dependency 'middlegem', '0.1.0'
  spec.add_dependency 'rails', '~> 6.1.3', '>= 6.1.3.2'
end
