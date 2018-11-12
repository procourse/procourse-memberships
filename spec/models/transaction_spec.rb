require 'rails_helper'

describe ProcourseMemberships::Transaction do
    it "should initialize the Transaction object" do
        transaction = ProcourseMemberships::Transaction.new({
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

        expect(transaction.id).to eq(1)
        expect(transaction.user_id).to eq(-1)
        expect(transaction.product_id).to eq(1677)
        expect(transaction.transaction_id).to eq(1)
        expect(transaction.transaction_amount).to eq(2.76)
        expect(transaction.transaction_date).to eq("2018-12-12 13:00:00")
        expect(transaction.billing_address).to eq("555 Main Street, East South West Central, Anyplace, State US")
        expect(transaction.credit_card).to eq("x5655")
        expect(transaction.paypal).to eq(nil)
    end
end