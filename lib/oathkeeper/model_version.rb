module OathKeeper
  class VersionGroup
    attr_accessor :meta, :versions
    def initialize(klass)
      @klass = klass
      @sub_types = []
      @versions = []
    end

    def add_sub_event(type,finder)
      @sub_types << {:type=> type, :finder => finder}
    end

    def type
      @klass
    end

    def add_version_and_event(instance)
      begin
        _klass = instance.class
        vobj = sub_type(_klass)[:finder].call(instance)
        versions << OathKeeper::ModelVersion.new(vobj) unless has_version?(vobj.id)
        create_master_event(vobj) unless has_master_event?
      rescue NoMethodError => e
        #rescuing from creating master_event from a new class that has no profile
      end
    end

    def create_master_event(obj)
      params = {:action => "update",
                :type => "Package",
                :object => obj.attributes.except("created_at","updated_at"),
                :pk => obj.id,
                :meta => meta.call(obj)}
      e = OathKeeper::VEvent.new(params)
      OathKeeper::add_event(e)
      OathKeeper.current_request_group.master_event = true
    end

    def has_master_event?
      unless OathKeeper.current_request_group.nil?
        return OathKeeper.current_request_group.master_event
      end
      false
    end

    def has_version?(id)
      @versions.map(&:id).include?(id)
    end

    def sub_types
      @sub_types.map {|x| x[:type]}
    end

    def sub_type(t)
      @sub_types.select {|x| x[:type] == t}.first
    end
  end

end

module OathKeeper
  class ModelVersion

    attr_accessor :id, :version

    def initialize(obj)
      @obj = obj
      @id = @obj.id
      serialize
    end

    def serialize
      pj = PackageSerializer.new(@obj).as_json
      @serialized = Marshal.dump(pj)
    end

    def mongo_id
      {"a" => @obj.app_id, "pk" => @id, "t" => "package"}
    end

    def dump(t,oid)
      {"p" => BSON::Binary.new(@serialized), "oid" => oid, "ts" => t}
    end

  end
end
