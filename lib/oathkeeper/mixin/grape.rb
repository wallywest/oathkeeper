module OathKeeper
  module StatusMixin
    module Grape
      def status_info
        @request_info ||=
        {
          :ip => env["REMOTE_ADDR"],
          :user => "racc_admin",
          :audit_type => "status",
          :ts => ::Time.now.utc,
        }
      end

      def db_restore_audit(app_id,ts)
        status_info[:app_id] = app_id
        status_info[:event] = 
          {
            :action => "restore",
            :type => "database",
            :restore_time => ts
          }

        rg = OathKeeper::StatusEvent.new(status_info)
        OathKeeper::Adapter.write(rg) if audit_enabled?
      end

      def audit_enabled?
        OathKeeper.enabled?
      end
    end
  end
end
