import PaymentLogs from '../models/payment-logs';

export default Discourse.Route.extend({
  model() {
    return PaymentLogs.findAll();
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});