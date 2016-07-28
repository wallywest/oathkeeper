module OathKeeper
  class CollectionEvent
    SCHEMA = [
      [:action, String],
      [:type, String],
      [:collection, Array],
      [:meta, Hash],
      [:changed, Hash]
    ]
    def initialize(e={})
      self.extend(Virtus.model)
      return if e.empty?
      SCHEMA.each do |schema|
        field,type = schema[0],schema[1]

        if e.has_key?(field)
          self.attribute field,type
          self.instance_variable_set("@#{field.to_s}",e[field])
        end
      end
    end
    
    def set_and_merge(type,value)
      unless self.attributes.include?(type)
        self.attribute type, class_from_type(type)
        self.instance_variable_set("@#{type.to_s}",{})
      end
      self.instance_variable_get("@#{type.to_s}").merge!(value)
    end

    def set_and_update(type,value)
      unless self.attributes.include?(type)
        self.attribute type, class_from_type(type)
      end
      self.instance_variable_set("@#{type.to_s}",value)
    end

    def class_from_type(type)
      SCHEMA.find {|x| x[0] == type}[1]
    end

    def audit
      OathKeeper::add_event(self) if OathKeeper.enabled?
    end
  end
end
