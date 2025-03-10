# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'slack-notification'
  spec.version       = '0.1.18'
  spec.date          = '2025-03-05'
  spec.authors       = ['Julian Fiander']
  spec.email         = ['julian@fiander.one']

  spec.summary       = 'A simplified Slack API.'
  spec.description   = 'A simplified Slack API for integration into Rails applications.'
  spec.homepage      = 'https://github.com/jfiander/slack-notification'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jfiander/slack-notification'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'

  spec.add_development_dependency 'bundler',   '~> 2.0'
  spec.add_development_dependency 'rake',      '~> 12.3', '>= 12.3.3'
  spec.add_development_dependency 'rspec',     '~> 3.8',  '>= 3.8.0'
  spec.add_development_dependency 'rubocop',   '~> 0.93', '>= 0.93.1'
  spec.add_development_dependency 'simplecov', '~> 0.16', '>= 0.16.1'

  spec.add_runtime_dependency 'slack-notifier', '~> 2.3'
end
