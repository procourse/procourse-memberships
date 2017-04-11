require_relative 'credit_card'

module DiscourseLeague 
  module Billing 
    class NetworkTokenizationCreditCard < DiscourseLeague::Billing::CreditCard
      self.require_verification_value = false
      self.require_name = false

      attr_accessor :payment_cryptogram, :eci, :transaction_id
      attr_writer :source

      SOURCES = [:apple_pay, :android_pay]

      def source
        if defined?(@source) && SOURCES.include?(@source)
          @source
        else
          :apple_pay
        end
      end

      def credit_card?
        true
      end

      def type
        "network_tokenization"
      end
    end
  end
end