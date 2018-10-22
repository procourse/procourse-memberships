import Subscriptions from '../models/subscriptions';

export default Discourse.Route.extend({
  model(opts) {
    return Subscriptions.findById(opts.user_id, opts.id);
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});