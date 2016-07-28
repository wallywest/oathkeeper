module OathKeeper
  class Config
    attr_accessor :enabled,:collection,:env,:settings,:adapter,:path,:connection

    def self.enabled=(value)
      @@config.enabled = value
    end

    def self.config
      @@config
    end

    def self.config=(config)
      @@config = config
    end

    def self.load!(env,config)
      settings = YAML.load(ERB.new(File.new(config).read).result)
      config = new(env,settings)
      self.config = config

      @@config.setup_db
    end

    def self.load_failover!
      @@config.setup_filesystem
    end

    def initialize(env,settings)
      @enabled = true
      @env = env
      @settings = settings
    end

    def setup_filesystem
      @adapter = :FileSystemAdapter
      @path = @settings[@env]["git"]
    end

    def setup_db
      settings = @settings[@env]
     # git_path = @settings["git"]
      @collection = settings["collection"]
      case @env
      when "test"
        setup_local(settings)
      when "development"
        if settings["hosts"].size > 1
          setup_replica_set(settings)
        else
          setup_local(settings)
        end
      else
        setup_replica_set(settings)
      end
    end

    def setup_local(setting)
      db = setting["db"]
      host,port = setting["hosts"].first.split(":")
      @conn = ::Mongo::Connection.new(host,port,:pool_size => 5,:pool_timeout => 5)
      @db = @conn[db]
      @adapter = :MongoAdapter
    end

    def setup_replica_set(setting)
      @prefix = setting["prefix"]
      hosts = setting["hosts"]
      db = setting["db"]
      user = setting["user"]
      pass = setting["password"]

      @conn = ::Mongo::MongoReplicaSetClient.new(hosts,:read => :primary_preferred)
      @db =  @conn[db]
      @db.authenticate(user,pass)
      @adapter = :MongoAdapter
    end

    def collection(name)
      col = "#{@collection}_#{name}"
      @db[col]
    end

    def connection
      @conn
    end

    def disconnect
      connection.close
    end

    def reconnect
      setup_db
    end

  end
end
