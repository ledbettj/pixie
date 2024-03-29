# frozen_string_literal: true

require_relative 'lib/pixie/version'

Gem::Specification.new do |spec|
  spec.name = "pixie"
  spec.version = Pixie::VERSION
  spec.authors = ['John Ledbetter']
  spec.email = ['john.ledbetter@gmail.com']

  spec.summary = 'WS281x wrapper'
  spec.homepage = 'https://www.weirdhorse.party'
  spec.license = 'MIT'
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'ffi', '~> 1.15'
  spec.add_dependency 'kodachroma', '~> 1.0'
  spec.add_dependency 'drb', '~> 2.1'
  spec.add_dependency 'numo-pocketfft', '~> 0.4'
  spec.add_dependency 'sinatra', '~> 2.1'
end
