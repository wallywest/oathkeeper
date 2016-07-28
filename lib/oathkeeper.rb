require 'singleton'
require 'time'
require 'virtus'
require 'lumberjack'

require "active_support/core_ext"
require "active_support/concern"

require 'mongo'
require 'bson'

require 'oathkeeper/railtie.rb' if defined?(Rails)


require 'oathkeeper/helpers'
require "oathkeeper/audit"
require 'oathkeeper/dsl'
require "oathkeeper/watcher"
require "oathkeeper/model_version"
require 'oathkeeper/config'
require 'oathkeeper/version'
require 'oathkeeper/error'
require 'oathkeeper/adapter'
require 'oathkeeper/adapter/mongo'
require 'oathkeeper/adapter/filesystem'
require 'oathkeeper/client'

require 'oathkeeper/mixin'
require "oathkeeper/mixin/grape"
require 'oathkeeper/event/collection'
require 'oathkeeper/event/event'
require 'oathkeeper/event/status_event'
require "oathkeeper/request_group"
require 'oathkeeper/middleware'

module OathKeeper
  include Helpers
  class << self


    def enabled?
      OathKeeper.config.enabled
    end

    def mongo(collection)
      OathKeeper.config.collection(collection)
    end
    
    def storage
      Thread.current[:oathkeeper] ||= {}
    end

    def store(key,value)
      OathKeeper.storage[key.to_sym] = value
    end
    
    def log_file_path
      if defined?(Rails)
        File.join(Rails.root,'log','oathkeeper.log')
      end
    end

    def logger=(logger)
      @logger = logger
    end

    def logger
      @logger ||= begin
                    Lumberjack::Logger.new(log_file_path, :roll => :daily)
                  end
    end

    def adapter
      OathKeeper.config.adapter
    end

    def set_adapter(type)
      OathKeeper.config.adapter = type
    end

    def controller_info=(data)
      OathKeeper.storage[:rg] = data
    end

    def current_id
      OathKeeper.storage[:rg]["id"]
    end

    def current_request_group
      OathKeeper.storage[:current_rg]
    end

    def add_version_group(g)
      OathKeeper.version_definitions << g
    end

    def find_version_group(type)
      version_definitions.select {|t| t.type == type}.first
    end

    def version_definitions
      @@definitions ||= []
    end

    def clear_stored_versions
      version_definitions.each {|x| x.versions = []}
    end

    def clear_storage
      Thread.current[:oathkeeper] = {}
    end

    def config
      @@config ||= OathKeeper::Config::config
    end

    def disconnect!
     OathKeeper.config.disconnect
    end

    def reconnect
     OathKeeper.config.reconnect
    end

    def add_event(event)
      rgd = OathKeeper.storage[:rg]

      if OathKeeper.current_request_group.nil?
        rg = OathKeeper::RequestGroup.new(rgd)
        OathKeeper.store(:current_rg,rg)
      else
        rg = OathKeeper.storage[:current_rg]
      end
      rg.add_event(event)
    end

  end
end

ActiveSupport.on_load(:active_record) do
  include OathKeeper::Audits
end

ActiveSupport.on_load(:action_controller) do
  include OathKeeper::Watcher
end
