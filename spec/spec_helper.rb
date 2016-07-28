ENV['RAILS_ENV'] = 'test'

require 'rails/all'
require 'rails_app/config/environment'
require 'rspec/rails'
require 'oathkeeper'
require 'oathkeeper_spec_helper'
require 'pry'

SPEC_ROOT = Pathname.new(File.expand_path('../', __FILE__))

Dir[SPEC_ROOT.join('support/*.rb')].each{|f| require f }

file = File.join(File.dirname(__FILE__), "oathkeeper.yml")
OathKeeper::Config.load!("test",file)

RSpec.configure do |config|
  config.include OathKeeperSpecHelpers

  config.before(:suite) do
    OathKeeper::Config.enabled = true
  end

  config.use_transactional_fixtures = true
  config.filter_run_excluding :exclude => true
end
