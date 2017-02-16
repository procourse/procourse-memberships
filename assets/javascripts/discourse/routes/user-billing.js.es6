import Subscriptions from '../models/subscriptions';
import Transactions from '../models/transactions';

export default Discourse.Route.extend({
  model() {
    this.set('loading', true);
    var result = Ember.RSVP.hash({
        subscriptions: Subscriptions.findAll(this.currentUser.id),
        transactions: Transactions.findAll(this.currentUser.id)
    });
    this.set('loading', false);
    return result;
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