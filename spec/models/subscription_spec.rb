require 'rails_helper'

describe ProcourseMemberships::Subscription do
    it "should initialize the Subscription object" do
        subscription = ProcourseMemberships::Subscription.new({
            :id => 1,
            :user_id => -1,
            :product_id => 1677,
            :subscription_id => 1,
            :subscription_end_date => "2018-12-12 13:00:00",
            :created_at => "2018-11-12 13:00:00",
            :active => true
        })

        expect(subscription.id).to eq(1)
        expect(subscription.user_id).to eq(-1)
        expect(subscription.product_id).to eq(1677)
        expect(subscription.subscription_id).to eq(1)
        expect(subscription.subscription_end_date).to eq("2018-12-12 13:00:00")
        expect(subscription.created_at).to eq("2018-11-12 13:00:00")
        expect(subscription.active).to eq(true)
    end
end