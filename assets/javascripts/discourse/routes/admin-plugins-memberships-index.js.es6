import paymentLogs from '../models/payment-logs';

export default Discourse.Route.extend({
  model() {
    return;
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});