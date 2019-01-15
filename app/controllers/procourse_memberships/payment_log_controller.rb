module ProcourseMemberships
    class PaymentLogController < ApplicationController
  
      def all
        logs = PluginStore.get("procourse_memberships", "log") || []

        if !logs.empty?
          logs = logs.flatten.map{ |log| PaymentLog.new(log) } if !logs.empty?
        else
          logs = []
        end

        render_json_dump(serialize_data(logs, PaymentLogSerializer))
      end
          
    end
  end