import PaymentLogs from '../models/payment-logs';
import debounce from "discourse/lib/debounce";

export default Ember.Controller.extend({
  loading: false,
  filter: null,

  show: debounce(function() {
    this.set("loading", true);
    PaymentLogs.findAll(this.get("filter")).then(result => {
      this.set("model", result);
      this.set("loading", false);
    });
  }, 250).observes("filter")
})