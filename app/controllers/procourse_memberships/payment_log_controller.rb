module ProcourseMemberships
    class PaymentLogController < ApplicationController
  
      def all
        filter = params[:filter]
        logs = PluginStore.get("procourse_memberships", "log") || []

        if !logs.empty?
          logs = logs.select {|log| log["timestamp"] == filter || log["username"] == filter || log["type"] == filter || log["amount"] == filter} if !filter.nil?
          logs = logs.flatten.map{ |log| PaymentLog.new(log) }
        else
          logs = []
        end

        logs.reverse!

        render_json_dump(serialize_data(logs, PaymentLogSerializer))
      end
          
    end
  end