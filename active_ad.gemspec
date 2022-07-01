require_relative 'lib/active_ad/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_ad'
  spec.version       = ActiveAd::VERSION
  spec.authors       = ['Kobus Joubert']
  spec.email         = ['kobus@translate3d.com']

  spec.summary       = 'Framework to manage ads.'
  spec.description   = 'Active Ad allows you to talk to different marketing APIs in a simple unified way giving you a consistent interface across all marketing APIs, no need to learn all the different social media APIs out there. The aim of the project is to feel natural to Ruby users and is developed to be used in Ruby on Rails applications, but can also be used as a stand alone library in any Ruby project.'
  spec.homepage      = 'https://github.com/kobusjoubert/active_ad'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kobusjoubert/active_ad'
  spec.metadata['changelog_uri']   = 'https://github.com/kobusjoubert/active_ad/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel',         '~> 7.0'
  spec.add_dependency 'activesupport',       '~> 7.0'
  spec.add_dependency 'faraday',             '~> 1.4'
  spec.add_dependency 'faraday_middleware',  '~> 1.0'
  spec.add_dependency 'i18n',                '~> 1.8'
  spec.add_dependency 'zeitwerk',            '~> 2.4'

  spec.add_development_dependency 'debug',               '~> 1.0'
  spec.add_development_dependency 'listen',              '~> 3.5'
  spec.add_development_dependency 'rake',                '~> 13.0'
  spec.add_development_dependency 'rspec',               '~> 3.0'
  spec.add_development_dependency 'rubocop',             '~> 1.18'
  spec.add_development_dependency 'rubocop-performance', '~> 1.11'
  spec.add_development_dependency 'rubocop-rake',        '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec',       '~> 2.4'
  spec.add_development_dependency 'webmock',             '~> 3.13'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
