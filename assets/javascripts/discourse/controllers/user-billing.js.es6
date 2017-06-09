import { popupAjaxError } from 'discourse/lib/ajax-error';
import { ajax } from 'discourse/lib/ajax';
import Subscriptions from '../models/subscriptions';

export default Ember.Controller.extend({
  actions: {
    cancelSubscription: function(subscription){
      var self = this;
      return bootbox.confirm(I18n.t("league.cancel_confirmation"), I18n.t("no_value"), I18n.t("yes_value"), function(result) {
        if (result) {
          self.set('model.loading', true);
          Subscriptions.destroy(subscription.subscription_id).then(function(result){
            self.set('model.subscriptions', result);
            self.set('model.loading', false);
          });
        }
      });
    },

    viewReceipt: function(receipt){
      window.location.href = "/league/transactions/" + this.currentUser.id + "/" + receipt.transaction_id;
    },

    updateBilling: function(subscription){
      window.location.href = "/league/l/" + subscription.product.id;
    }
  }
})
