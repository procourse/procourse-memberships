require 'rails_helper'

describe ProcourseMemberships::Transaction do
    it "should initialize the Transaction object" do
        subscription = ProcourseMemberships::Transaction.new({
            :id => 1,
            :user_id => -1,
            :product_id => 1677,
            :transaction_id => 1,
            :transaction_amount => 2.76,
            :transaction_date => "2018-12-12 13:00:00",
            :billing_address => "555 Main Street, East South West Central, Anyplace, State US",
            :credit_card => "x5655",
            :paypal => nil,
        })

        expect(subscription.id).to eq(1)
        expect(subscription.user_id).to eq(-1)
        expect(subscription.product_id).to eq(1677)
        expect(subscription.transaction_id).to eq(1)
        expect(subscription.transaction_amount).to eq(2.76)
        expect(subscription.transaction_date).to eq("2018-12-12 13:00:00")
        expect(subscription.billing_address).to eq("555 Main Street, East South West Central, Anyplace, State US")
        expect(subscription.credit_card).to eq("x5655")
        expect(subscription.paypal).to eq(nil)
    end
end