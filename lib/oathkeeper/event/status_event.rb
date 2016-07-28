module OathKeeper
  class StatusEvent
    SCHEMA = [
      [:app_id, Integer],
      [:ip, String],
      [:audit_type , String],
      [:event, Hash],
      [:ip, String],
      [:ts, Time]
    ]

    def initialize(rg)

      self.extend(Virtus.model)

      SCHEMA.each do |schema|
        field,type,options = schema[0],schema[1],schema[2]

        if rg.has_key?(field)
          if options
            self.attribute field,type,options
          else
            self.attribute field,type
          end
          self.instance_variable_set("@#{field.to_s}",rg[field])
        end
      end
    end
  end
end

