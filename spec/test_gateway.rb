RSpec.shared_context "test gateway" do
  before(:each) do
    module ::ProcourseMemberships
      class Gateways
        class TestGateway
         def initialize
           "Test Gateway"
         end
         def purchase(user_id, product, nonce, options = {})
           return { :success => true, :message => 'Dummy purchase' }
         end

         def subscribe(user_id, product, nonce, options = {})
           return { :success => true, :message => 'Dummy subscribe' }
         end

         def execute(user_id, product, payment_id, payer_id)
           return {:success => true, :message => 'Dummy execute' }
         end

         def unsubscribe(subscription_id, options = {})
           return {:success => true, :message => 'Dummy unsubscribe' }
         end

         def update_payment(user_id, product, subscription_id, nonce, options = {})
           return {:success => true, :message => 'Dummy update payment' }
         end
        end
      end
    end
  end
  let(:gateway) { ::ProcourseMemberships::Gateways::TestGateway}
end
