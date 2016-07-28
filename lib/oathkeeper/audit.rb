module OathKeeper
  module Audits
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def oath_keeper(options = {}, &block)
        send :include, InstanceMethods
        cattr_accessor :meta,:version,:ignore,:master_event, :dsl
        if block_given?
          self.dsl = OathKeeper::DSL.new(&block)
        end

        self.ignore = ([options[:ignore]].flatten.compact || [])
        self.meta = options[:meta] || {}
        self.master_event = false

        #setting this will 
        # include meta of master event if defined
        # versioning of master event if defined
        version_definition(options[:version]) if options[:version]
        subevent_definition(options[:master_event]) if options[:master_event]

        after_create :record_create
        before_update :record_update
        before_destroy :record_destroy
      end

      def version_definition(version)
        definition = OathKeeper::VersionGroup.new(self)
        definition.meta = self.meta if self.meta
        OathKeeper.add_version_group(definition)
      end

      def subevent_definition(options)
        self.master_event = true
        type,finder = options[:type],options[:finder]
        vg = OathKeeper.find_version_group(type)
        vg.add_sub_event(self,finder) if vg
      end
    end

    module InstanceMethods
      IGNORE_COLUMNS = [
        "created_at",
        "updated_at",
        "modified_time",
        "app_id","id",
        "modified_time_unix",
        "last_request_at",
        "current_login_at",
        "salt",
        "persistence_token",
        "perishable_token"
      ].freeze

      def has_record_changed?
       !sum_changes.empty?
      end

      def sum_changes
        changes = changed - self.ignore
      end

      def gimme_key
        pk = self.class.primary_key
        self["#{pk}"]
      end

      def filter(attributes)
        attributes.except(*IGNORE_COLUMNS)
      end

      def record_create
        if OathKeeper.enabled? && self.class.to_s.match(/.+\:\:Deleted/).nil?
          data={
            :action=> 'create',
            :type => self.class.base_class.name,
            :pk => gimme_key,
            :object => filter(self.attributes)
          }

          write_action({:audit => data})
        end
      end

      def record_update
       obj = self.changes.reject {|k,v| self.ignore.include?(k)}
       if OathKeeper.enabled? && has_record_changed?
          data = {
            :action=> 'update',
            :type => self.class.base_class.name,
            :object => filter(self.attributes),
            :pk => gimme_key,
            :changed => filter(obj)
          }
        write_action({:audit => data}) unless data[:changed].empty?
       end
      end

      def record_destroy
        if OathKeeper.enabled?
          data = {
             :action => 'destroy',
             :pk => gimme_key,
             :type => self.class.base_class.name,
             :object => filter(self.attributes)
           }
           write_action({:audit => data})
        end
      end

      def write_action(d)
        trigger_master_event if self.master_event
        meta = find_meta

        d[:audit][:meta] = meta unless meta.empty?

        OathKeeper::add_event(d[:audit])
      end
    end

    def trigger_master_event
      definitions = OathKeeper.version_definitions
      definitions.select {|d| d.sub_types.include?(self.class)}.each do |d|
        d.add_version_and_event(self)
      end
    end

    def find_meta
      s = {}
      m = self.meta

      if m.class == Proc
        obj = m.call(self)
        s[obj.class] = obj
      elsif self.dsl
        dsl.parse!(self)
      else
        find_associated_data(m)
      end
    end

    def find_associated_data(m)
      s = {}
      m.each do |assoc|
        obj,method = assoc[0],assoc[1]
        reference = self.send(obj)
        s[obj] = reference.send(method) if reference
      end
      s
    end

  end
end

