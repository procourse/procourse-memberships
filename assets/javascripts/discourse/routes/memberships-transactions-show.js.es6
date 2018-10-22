import Transactions from '../models/transactions';

export default Discourse.Route.extend({
  model(opts) {
    return Transactions.findById(opts.user_id, opts.id);
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});