module OathKeeper
  class RequestGroup
    include Virtus.model

    #attr_accessor :ip,:user,:time,:controller,:action,:events,:app_id,:bucket,:changes,:assoc
    attr_accessor :bucket, :meta
    #, :master_event

    attribute :app_id, Integer
    attribute :ip, String
    attribute :user, String
    attribute :audit_type, String
    attribute :controller, String
    attribute :action, String
    attribute :ip, String
    attribute :ts, Time
    attribute :events, Array, :default => []
    attribute :changes, Integer, :default => 0
    attribute :master_event, Boolean, :default => false, :reader => :private

    def add_event(event)
      unless raw_event?(event)
       event = OathKeeper::VEvent.new(event.symbolize_keys)
      end
      self.events << event.to_hash.as_json
      self.changes += 1
    end

    def package_create?
      (@controller == "packages" && @action == "create")
    end
    
    def raw_event?(event)
      event.is_a?(OathKeeper::CollectionEvent) || event.is_a?(OathKeeper::VEvent)
    end

  end
end

