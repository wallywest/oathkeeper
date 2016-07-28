module OathKeeper
  module CustomAudit
    extend ActiveSupport::Concern

    module ClassMethods
      def audited_methods
        @audited_methods ||= []
      end

      def event(method,&block)
       audited_methods << {
          method => {
            :event => "OathKeeper::VEvent",
            :block => block,
          }
        }
      end

      def collection_event(method,&block)
       audited_methods << {
          method => {
            :event => "OathKeeper::CollectionEvent",
            :block => block,
          }
        }
      end

      def changed
        @changed ||= {}
      end
    end
    
    def self.changed
      @changed ||= {}
    end

    def audited_events
      self.class.audited_methods
    end

    def event_config(_method)
      audited_events.find {|x| x.keys.include?(_method)}[_method]
    end
    
    def event(_method)
      @event ||= event_config(_method)[:event].constantize.new
    end

    def audit_event(_method)
      instance_exec &event_config(_method)[:block]
      event(_method).audit
    end

    def add_field_change(_method,column,old,new)
      find_assoc(_method,column,new)
      change = {:type => :field, column=> [old,new]}
      event(_method).set_and_merge(:changed,change)
    end

    def add_assoc_change(_method,assoc,old,new)
      a = [find_null_blank_object(assoc,old), find_null_blank_object(assoc,new)]
      change = {assoc => a}
      event(_method).set_and_merge(:changed,change)
    end

    def find_null_blank_object(assoc,id)
      assoc = assoc.to_s
      begin 
        obj = assoc.classify.constantize.find(id).attributes.except("created_at","updated_at","modified_time")
      rescue ActiveRecord::RecordNotFound,NoMethodError
        obj = nil
      end
      obj
    end

    def add_to_meta(_method,value)
      event(_method).set_and_merge(:meta,value)
    end

    def find_assoc(_method,column,id)
      return if (id.nil? || id == 0)
      name = column.gsub(/_id/,'')
      obj = name.classify.constantize.find(id)
      add_to_meta(_method,{name=> obj.attributes.except("created_at","updated_at","modified_time")}) unless obj.nil?
    end

    def action(value)
      @event.set_and_update(:action,value)
    end

    def type(value)
      @event.set_and_update(:type,value)
    end

    def meta(value)
      m = {}.tap do |h|
        value.each do |k,v|
          if v.is_a?(ActiveRecord::Base)
            h[k] = v.attributes.except("created_at","updated_at","modified_time")
          else
            h[k] = v
          end
        end
      end
      @event.set_and_merge(:meta,m)
    end

    def collection(value)
      @event.set_and_update(:collection ,value.map {|x| x.attributes.except("created_at","updated_at","modified_time")})
    end
    
    def object(value)
      @event.set_and_update(:object,value.as_json)
    end

  end
end
