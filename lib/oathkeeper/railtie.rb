# encoding: utf-8
require 'oathkeeper'
require 'oathkeeper/config'
require 'rails/railtie'

module OathKeeper
  class Railtie < ::Rails::Railtie
    config.oathkeeper = ActiveSupport::OrderedOptions.new
    config.oathkeeper.enabled = true

    initializer "setup database" do
      config_file = Rails.root.join("config", "oathkeeper.yml")

      if config_file.file?
        env = Rails.env || 'development'
        begin
          ::OathKeeper::Config.load!(env,config_file)
        rescue ::Mongo::ConnectionFailure => e
          unless env == "test"
            handle_configuration_error(e) 
            #::OathKeeper::Config.load_failover!
          end
        end
      else
        raise ConfigError, "Oathkeeper.yml does not exist"
      end
    end

    initializer "environment enabled flag" do
       config.after_initialize do
         ::OathKeeper::Config.enabled = config.oathkeeper.enabled
       end
    end

    def handle_configuration_error(e)
     Rails.logger.info("Cannot connect to MongoDB")
     Rails.logger.info(e.message)
     Rails.logger.info("Failing over to FileSystem Adapter")
    end

  end
end
