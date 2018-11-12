require 'rails_helper'

describe 'transaction serializer' do

    it 'returns a serialized transaction object' do
        transaction = ProcourseMemberships::TransactionSerializer.new({
            :id => 1,
            :product_id => 1677,
            :transaction_id => 1,
            :transaction_amount => 2.76,
            :transaction_date => "2018-12-12 13:00:00",
            :billing_address => "555 Main Street, East South West Central, Anyplace, State US",
            :credit_card => "x5655",
            :paypal => nil,
        })

        expect(transaction.object[:id]).to eq(1)
        expect(transaction.object[:product_id]).to eq(1677)
        expect(transaction.object[:transaction_id]).to eq(1)
        expect(transaction.object[:transaction_amount]).to eq(2.76)
        expect(transaction.object[:transaction_date]).to eq("2018-12-12 13:00:00")
        expect(transaction.object[:billing_address]).to eq("555 Main Street, East South West Central, Anyplace, State US")
        expect(transaction.object[:credit_card]).to eq("x5655")
        expect(transaction.object[:paypal]).to eq(nil)
    end
end