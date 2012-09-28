# -*- encoding: utf-8 -*-
require File.expand_path('../lib/kyototycoon-store/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["babatakao"]
  gem.email         = ["babatakao@gmail.com"]
  gem.description   = %q{ActiveSupport::Cache KyotoTycoon Store}
  gem.summary       = %q{ActiveSupport::Cache KyotoTycoon Store}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "kyototycoon-store"
  gem.require_paths = ["lib"]
  gem.version       = Kyototycoon::Store::VERSION

  gem.add_dependency('kyototycoon', '>=0.6.1')
  gem.add_dependency('activesupport', '~>3.1')
  gem.add_dependency('rspec', '~>2.10')
  gem.add_dependency('simplecov', '>=0')
end
