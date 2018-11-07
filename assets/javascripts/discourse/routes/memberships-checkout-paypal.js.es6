import PayPal from '../models/paypal';

export default Discourse.Route.extend({
  model(opts) {
    return PayPal.logPayPalSuccess(opts.token, opts.PayerID, opts.product);
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});