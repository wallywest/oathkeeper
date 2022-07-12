# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "oathkeeper/version"

Gem::Specification.new do |gem|
  gem.authors = ["Justin Erny"]
  gem.platform = Gem::Platform::RUBY
  gem.email = 'jerny@vail.com'
  gem.rdoc_options = ["--main", "README.rdoc", "--line-numbers", "--inline-source"]
  gem.name = 'oathkeeper'
  gem.summary = %q{dumps audit events to mongo in racc web app}
  gem.version = OathKeeper::VERSION
  gem.date = Time.now.strftime('%Y-%m-%d')
  gem.description = "Track db/audited changes in racc web portal"

  gem.add_runtime_dependency 'mongo', "~>1.12.x", "<2.0.0"
  gem.add_runtime_dependency "active_model_serializers"
  gem.add_runtime_dependency "virtus"
  gem.add_runtime_dependency "origin"
  gem.add_runtime_dependency "lumberjack"
  gem.add_runtime_dependency "bson", "~>1.12.x", '<2.0.0'

  gem.add_development_dependency 'activerecord', '4.2.11.3'
  gem.add_development_dependency 'sqlite3' unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-rails'

  gem.test_files    = gem.files.grep(/^spec\//)
  gem.files = `git ls-files`.split("\n")
  gem.require_paths = ["lib"]
end

