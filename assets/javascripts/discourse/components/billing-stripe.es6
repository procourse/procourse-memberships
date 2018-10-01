import computed from "ember-addons/ember-computed-decorators";
import { observes, on } from 'ember-addons/ember-computed-decorators';
import { ajax } from 'discourse/lib/ajax';
import loadScript from 'discourse/lib/load-script';
import Payment from '../models/payment';

export default Ember.Component.extend({
    @computed('showBilling')
    showSubmitButton(showBilling){
        return showBilling === true ? 'hidden' : undefined;
    },

    @computed('showBilling')
    showContinueButton(showBilling){
        return showBilling === true ? true : false;
    },
    @computed('showStripe')
    showStripeButton(showStripe){
        return showStripe === true ? true : false;
    },
    actions: {
        submitStripe(params){
            let result = Payment.submitNonce(self.get('leagueLevel')[0].id, params, false);
            this.set('showLoading', true);
            result.then((response) => {
                this.set("showCompleted", true);
                this.set('checkoutState', 'completed');
                this.set('showStripe', false);
            });
        }
    }    
});
