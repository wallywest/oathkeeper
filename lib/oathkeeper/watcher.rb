module OathKeeper
  module Watcher
    def self.included(base)
      base.before_filter :watch_request
      base.after_filter :request_end
    end
    private

    def watch_request
      return unless OathKeeper.enabled?
      OathKeeper.clear_storage

      OathKeeper.controller_info = cont_data
      user_audit("logout") if session_destroy
    end
    
    def cont_data
      {
        :ip => env["action_dispatch.remote_ip"].to_s || "127.0.0.1",
        :user => get_current_user,
        :id => env["action_dispatch.request_id"],
        :controller => env["action_dispatch.request.parameters"]["controller"],
        :action => env["action_dispatch.request.parameters"]["action"],
        :audit_type => "model",
        :ts => ::Time.now.utc,
        :app_id => session["app_id"]
      }
    end

    def request_end
      return unless OathKeeper.enabled?

      user_audit("login") if session_create
      rg = OathKeeper.current_request_group
      OathKeeper::Adapter::write(rg) unless rg.nil?
      OathKeeper.clear_stored_versions
    end

    def user_audit(action)
      return if current_user.nil?
      cu = current_user.attributes
      rg = OathKeeper.storage[:rg]
      rg[:app_id]  = cu["app_id"]
      rg.merge!({:controller => "Session", :action => action, :user => cu["login"]})
      OathKeeper::Adapter::write(rg)
    end


    def get_current_user
      if Rails.env == "development"
        return if self.class.ancestors.include?(Jasminerice::ApplicationController)
      end

      return "racc_system" if current_user.nil?
      current_user[:login]
    end

    def session_destroy
      params[:controller] == "user_sessions" && params[:action] == "destroy"
    end
    
    def session_create
      params[:controller] == "user_sessions" && params[:action] == "create"
    end

  end
end
