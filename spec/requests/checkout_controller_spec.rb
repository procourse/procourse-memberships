require 'rails_helper'
require_relative '../test_gateway'

describe ProcourseMemberships::CheckoutController do
  let(:description) { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tempor justo turpis, id bibendum est placerat ac. Fusce mollis felis in mauris molestie lobortis. Nunc elementum fermentum dui, at congue ex auctor sit amet. Maecenas enim mauris, iaculis in ligula eu, commodo sollicitudin purus. Fusce ultricies nulla lorem, in rutrum orci semper nec. Etiam eleifend diam non ante interdum, ut laoreet ipsum fringilla. Integer venenatis dignissim malesuada.' }
  # Fabricate a level
  let(:level) do
    PluginStore.set('procourse_memberships', 'levels', [{
        id: '1',
        name: 'Dummy Level',
        enabled: true,
        group: @group.id.to_s,
        trust_level: 0,
        initial_payment: 10,
        recurring: false,
        description_raw: description,
        description_cooked: description,
        welcome_message: description
    }])
  end

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
      subscription_id: 'abcde',
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
      context 'when user is not part of the group' do
        before do
          @group = group
          @user = Fabricate(:user)
          sign_in(@user)
        end

        it 'successfully completes the transaction' do
          level
          gateway
          post '/memberships/checkout/submit-payment.json', params: { :level_id => 1, :nonce => 'testNonce' }
          expect(response.status).to eq(200)
        end
      end

      context 'when user is part of the group' do
        before do
          @group = group
          @user = Fabricate(:user)
          @group.add(@user)
          @group.save
          sign_in(@user)
        end
        it 'should raise the right error' do
          level
          gateway
          post '/memberships/checkout/submit-payment.json', params: { :level_id => 1, :nonce => 'testNonce' }
          expect(response.status).to eq(422)
        end
      end
    end
    describe 'subscribing a level' do
      context 'when user is not part of the group' do
        before do
          @group = group
          @user = Fabricate(:user)
          sign_in(@user)
        end

        it 'successfully completes the transaction' do
          recurring_level
          gateway
          post '/memberships/checkout/submit-payment.json', params: { :level_id => 2, :nonce => 'testNonce' }
          expect(response.status).to eq(200)
        end
      end

      context 'when user is part of the group' do
        before do
          @group = group
          @user = Fabricate(:user)
          @group.add(@user)
          @group.save
          sign_in(@user)
        end

        it 'should raise the right error' do
          recurring_level
          gateway
          post '/memberships/checkout/submit-payment.json', params: { :level_id => 2, :nonce => 'testNonce' }
          expect(response.status).to eq(422)
        end
      end
    end
    describe 'executing payment' do
      context 'when user is not part of the group' do
        before do
          @group = group
          @user = Fabricate(:user)
          sign_in(@user)
        end

        it 'successfully completes the transaction' do
          level
          gateway
          post '/memberships/checkout/submit-payment.json', params: { :level_id => 1, :nonce => 'testNonce', :update => 'execute' }
          expect(response.status).to eq(200)

        end
      end

      context 'when user is part of the group' do
        before do
          @group = group
          @user = Fabricate(:user)
          @group.add(@user)
          @group.save
          sign_in(@user)
        end

        it 'should raise the right error' do
          level
          gateway
          post '/memberships/checkout/submit-payment.json', params: { :level_id => 1, :nonce => 'testNonce', :update => 'execute' }
          expect(response.status).to eq(422)
        end
      end

    end
    describe 'updating billing' do
      context 'when user is subscribed to level' do
        before do
          @group = group
          @user = Fabricate(:user)
          @group.add(@user)
          @group.save
          sign_in(@user)
        end

        it 'should successfully update billing info' do
          recurring_level
          gateway
          subscription

          post '/memberships/checkout/submit-payment.json', params: { :level_id => 2, :nonce => nil, :update => true }, as: :json
          expect(response.status).to eq(200)
        end
      end

      context 'when user does not have a subscription' do
        before do
          @group = group
          @user = Fabricate(:user)
          sign_in(@user)
        end

        it 'should raise the right error' do
          recurring_level
          gateway

          post '/memberships/checkout/submit-payment.json', params: { :level_id => 2, :nonce => nil, :update => true }, as: :json
          expect(response.status).to eq(422)
        end
      end
    end
  end
end
