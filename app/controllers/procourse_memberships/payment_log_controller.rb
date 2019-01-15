module ProcourseMemberships
    class PaymentLogController < ApplicationController
  
      def all
        filter = params[:filter]
        logs = PluginStore.get("procourse_memberships", "log") || []

        if !logs.empty?
          logs = logs.flatten.map{ |log| PaymentLog.new(log) }
          #todo - handle filtering of logs
        else
          logs = []
        end

        logs.reverse!

        render_json_dump(serialize_data(logs, PaymentLogSerializer))
      end
          
    end
  end