require_relative '../gateways'

module ActiveMerchant
  module Billing
    class PaypalExpressGateway
      
      def subscribe(user_id, product, credit_card_or_vault_id, options = {})
        commit 'CreateRecurringPaymentsProfile', build_create_profile_request(options)
      end

      def unsubscribe(subscription_id, options = {})
        commit 'ManageRecurringPaymentsProfileStatus', build_manage_profile_request(subscription_id, 'Cancel', options)
      end
      private

      def build_create_profile_request(options)
        xml = Builder::XmlMarkup.new :indent => 2
        xml.tag! 'CreateRecurringPaymentsProfileReq', 'xmlns' => PAYPAL_NAMESPACE do
          xml.tag! 'CreateRecurringPaymentsProfileRequest', 'xmlns:n2' => EBAY_NAMESPACE do
            xml.tag! 'n2:Version', API_VERSION
            xml.tag! 'n2:CreateRecurringPaymentsProfileRequestDetails' do
              xml.tag! 'Token', options[:token] unless options[:token].blank?
              if options[:credit_card]
                add_credit_card(xml, options[:credit_card], (options[:billing_address] || options[:address]), options)
              end
              xml.tag! 'n2:RecurringPaymentsProfileDetails' do
                xml.tag! 'n2:BillingStartDate', (options[:start_date].is_a?(Date) ? options[:start_date].to_time : options[:start_date]).utc.iso8601
                xml.tag! 'n2:ProfileReference', options[:profile_reference] unless options[:profile_reference].blank?
              end
              xml.tag! 'n2:ScheduleDetails' do
                xml.tag! 'n2:Description', options[:description]
                xml.tag! 'n2:PaymentPeriod' do
                  xml.tag! 'n2:BillingPeriod', options[:period] || 'Month'
                  xml.tag! 'n2:BillingFrequency', options[:frequency]
                  xml.tag! 'n2:TotalBillingCycles', options[:total_billing_cycles] unless options[:total_billing_cycles].blank?
                  xml.tag! 'n2:Amount', amount(options[:amount]), 'currencyID' => options[:currency] || 'USD'
                  xml.tag! 'n2:TaxAmount', amount(options[:tax_amount] || 0), 'currencyID' => options[:currency] || 'USD' unless options[:tax_amount].blank?
                  xml.tag! 'n2:ShippingAmount', amount(options[:shipping_amount] || 0), 'currencyID' => options[:currency] || 'USD' unless options[:shipping_amount].blank?
                end
                if !options[:trial_amount].blank?
                  xml.tag! 'n2:TrialPeriod' do
                    xml.tag! 'n2:BillingPeriod', options[:trial_period] || 'Month'
                    xml.tag! 'n2:BillingFrequency', options[:trial_frequency]
                    xml.tag! 'n2:TotalBillingCycles', options[:trial_cycles] || 1
                    xml.tag! 'n2:Amount', amount(options[:trial_amount]), 'currencyID' => options[:currency] || 'USD'
                    xml.tag! 'n2:TaxAmount', amount(options[:trial_tax_amount] || 0), 'currencyID' => options[:currency] || 'USD' unless options[:trial_tax_amount].blank?
                    xml.tag! 'n2:ShippingAmount', amount(options[:trial_shipping_amount] || 0), 'currencyID' => options[:currency] || 'USD' unless options[:trial_shipping_amount].blank?
                  end
                end
                if !options[:initial_amount].blank?
                  xml.tag! 'n2:ActivationDetails' do
                    xml.tag! 'n2:InitialAmount', amount(options[:initial_amount]), 'currencyID' => options[:currency] || 'USD'
                    xml.tag! 'n2:FailedInitialAmountAction', options[:continue_on_failure] ? 'ContinueOnFailure' : 'CancelOnFailure'
                  end
                end
                xml.tag! 'n2:MaxFailedPayments', options[:max_failed_payments] unless options[:max_failed_payments].blank?
                xml.tag! 'n2:AutoBillOutstandingAmount', options[:auto_bill_outstanding] ? 'AddToNextBilling' : 'NoAutoBill'
              end
            end
          end
        end
        xml.target!
      end

      def build_manage_profile_request(profile_id, action, options)
        xml = Builder::XmlMarkup.new :indent => 2
        xml.tag! 'ManageRecurringPaymentsProfileStatusReq', 'xmlns' => PAYPAL_NAMESPACE do
          xml.tag! 'ManageRecurringPaymentsProfileStatusRequest', 'xmlns:n2' => EBAY_NAMESPACE do
            xml.tag! 'n2:Version', API_VERSION
            xml.tag! 'n2:ManageRecurringPaymentsProfileStatusRequestDetails' do
              xml.tag! 'ProfileID', profile_id
              xml.tag! 'n2:Action', action
              xml.tag! 'n2:Note', options[:note] unless options[:note].blank?
            end
          end
        end
        xml.target!
      end

    end
  end
end

module DiscourseLeague
  class Gateways
    class PayPal

      def initialize(options = {})
        @options = options
      end

      def active_merchant
        gateway = ActiveMerchant::Billing::PaypalExpressGateway.new(
          :login => SiteSetting.league_paypal_username,
          :password => SiteSetting.league_paypal_password,
          :signature => SiteSetting.league_paypal_signature
        )
      end

    end
  end
end