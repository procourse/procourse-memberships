module ::ProcourseMemberships
    class PaymentLog
      alias :read_attribute_for_serialization :send
  
      attr_accessor :id, :timestamp, :username, :level_id, :type, :amount
  
      def initialize(opts={})
        @id = opts[:id]
        @timestamp = opts[:timestamp]
        @username = opts[:username]
        @level_id = opts[:level_id]
        @type = opts[:type]
        @amount = opts[:amount]
      end
  
    end
  end