import Subscriptions from '../models/subscriptions';
import Transactions from '../models/transactions';

export default Discourse.Route.extend({
  model() {
    this.set('loading', true);
    var subscriptions = Subscriptions.findAll(this.currentUser.id);
    var transactions = Transactions.findAll(this.currentUser.id);
    return {"subscriptions": subscriptions, "transactions": transactions};
  },

  setupController(controller, model) {
    if (this.currentUser.id !== this.modelFor("user").id){
      this.replaceWith('userActivity');
    }
    else{
      controller.setProperties({ model });
    };
  }
});