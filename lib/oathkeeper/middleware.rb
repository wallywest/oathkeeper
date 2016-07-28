module OathKeeper
  module Middleware
    class BeforeRequest
      def call(env)
        return unless OathKeeper.enabled?
        OathKeeper.clear_storage
        OathKeeper.controller_info = request_data(env)

        env
      end

      def request_data(env)
        request_method = env["REQUEST_METHOD"]
        if ["PUT", "POST", "DELETE", "PATCH"].include?(request_method)
          audit = env.fetch("rack.request.form_hash", nil).fetch("audit", nil)

          {
            :ip => audit['remote_ip'] || "127.0.0.1",
            :user => audit['username'],
            :controller => audit['controller'],
            :action => request_method,
            :audit_type => "model",
            :ts => ::Time.now.utc,
            :app_id => audit["app_id"]
          }
        else
          {}
        end
      end
    end

    class AfterRequest
      def call(env)
        rg = OathKeeper.current_request_group
        OathKeeper::Adapter::write(rg) unless rg.nil?
        OathKeeper.clear_stored_versions

        env
      end
    end
  end
end
