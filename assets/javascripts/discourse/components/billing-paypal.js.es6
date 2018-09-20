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
    
    @on('init')
    paypal() {
        var self = this;
        loadScript("https://www.paypalobjects.com/api/checkout.js", { scriptTag: true }).then(() => {
            paypal.Button.render({

                // Set up a getter to create a Payment ID using the payments api, on your server side:

                payment: function() {
                    return new paypal.Promise(function(resolve, reject) {

                        // Make an ajax call to get the Payment ID. This should call your back-end,
                        // which should invoke the PayPal Payment Create api to retrieve the Payment ID.

                        // When you have a Payment ID, you need to call the `resolve` method, e.g `resolve(data.paymentID)`
                        // Or, if you have an error from your server side, you need to call `reject`, e.g. `reject(err)`

                        let result = Payment.submitNonce(1, null, false);
                        result.then(response => {
                            console.log(response);
                        })
                    });
                },

                // Pass a function to be called when the customer approves the payment,
                // then call execute payment on your server:

                onAuthorize: function(data) {

                    console.log('The payment was authorized!');
                    console.log('Payment ID = ',   data.paymentID);
                    console.log('PayerID = ', data.payerID);

                    // At this point, the payment has been authorized, and you will need to call your back-end to complete the
                    // payment. Your back-end should invoke the PayPal Payment Execute api to finalize the transaction.

                    jQuery.post('/league/checkout/paypal/execute', { paymentID: data.paymentID, payerID: data.payerID })
                        .done(function(data) { /* Go to a success page */ })
                        .fail(function(err)  { /* Go to an error page  */  });
                },

                // Pass a function to be called when the customer cancels the payment

                onCancel: function(data) {

                    console.log('The payment was cancelled!');
                    console.log('Payment ID = ', data.paymentID);
                }

            }, '#paypal-button-container');
        });

    }
});
