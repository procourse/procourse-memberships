require 'rails_helper'
require_relative '../test_gateway'

describe ProcourseMemberships::SubscriptionsController do
  let(:description) { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tempor justo turpis, id bibendum est placerat ac. Fusce mollis felis in mauris molestie lobortis. Nunc elementum fermentum dui, at congue ex auctor sit amet. Maecenas enim mauris, iaculis in ligula eu, commodo sollicitudin purus. Fusce ultricies nulla lorem, in rutrum orci semper nec. Etiam eleifend diam non ante interdum, ut laoreet ipsum fringilla. Integer venenatis dignissim malesuada.' }

  let(:recurring_level) do
    PluginStore.set('procourse_memberships', 'levels', [{
        id: '2',
        name: 'Dummy Recurring Level',
        enabled: true,
        group: @group.id.to_s,
        trust_level: 0,
        initial_payment: 10,
        recurring: true,
        recurring_payment: 10,
        recurring_payment_period: 30,
        description_raw: description,
        description_cooked: description,
        welcome_message: description
    }])
  end

  let(:subscription) do
    PluginStore.set('procourse_memberships', "s:#{@user.id}", [{
      product_id: '2',
      subscription_id: '247',
      subscription_end_date: 'test',
      active: true,
      created_at: Time.now,
      updated_at: Time.now
    }])
  end

  let(:group) { Fabricate(:group, name: 'test_group') }

  before(:each) do
    SiteSetting.memberships_gateway = 'Test'
  end

  include_context 'test gateway'

  describe 'submitting a payment' do
    describe 'purchasing a level' do
      context 'when user is subscribed to the level' do
        before do
          @group = group
          @user = Fabricate(:user)
          @group.add(@user)
          @group.save
          sign_in(@user)
        end

        it 'successfully unsubscribes the user' do
          recurring_level
          gateway
          subscription
          delete '/memberships/subscriptions/247'
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
