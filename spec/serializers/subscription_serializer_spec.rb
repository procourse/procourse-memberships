require 'rails_helper'

describe 'subscription serializer' do

    it 'returns a serialized subscription object' do
        subscription = ProcourseMemberships::SubscriptionSerializer.new({
            :id => 1,
            :product => 1677,
            :subscription_id => 1,
            :subscription_end_date => "2018-12-12 13:00:00",
            :created_at => "2018-11-12 13:00:00",
            :active => true
        })

        expect(subscription.object[:id]).to eq(1)
        expect(subscription.object[:product]).to eq(1677)
        expect(subscription.object[:subscription_id]).to eq(1)
        expect(subscription.object[:subscription_end_date]).to eq("2018-12-12 13:00:00")
        expect(subscription.object[:created_at]).to eq("2018-11-12 13:00:00")
        expect(subscription.object[:active]).to eq(true)
    end
end