import computed from "ember-addons/ember-computed-decorators";
import { observes, on } from 'ember-addons/ember-computed-decorators';
import { ajax } from 'discourse/lib/ajax';
import loadScript from 'discourse/lib/load-script';
import Payment from '../models/payment';

const { computed: { alias }, observer } = Ember;

export default Ember.Component.extend({
    classNameBindings: ['showFormClass', 'showLoadingSpinner'],
    routing: Ember.inject.service('-routing'),
    params: alias('routing.router.currentState.routerJsState.fullQueryParams'),
    @computed('showBilling')
    showSubmitButton(showBilling){
        return showBilling === true ? 'hidden' : undefined;
    },

    @computed('showBilling')
    showContinueButton(showBilling){
        return showBilling === true ? true : false;
    },
    @computed('showPaypal')
    showPaypalButton(showPaypal){
        return showPaypal === true ? true : false;
    },
    @computed('paypalLoading')
    showLoading(paypalLoading){
      return paypalLoading;
    },
    @on('init')
    subscriptionProduct(){
        this.set("subscriptionProduct", true)
    },
    @on('init')
    goLiveSetting(){
        const liveSetting = Discourse.SiteSettings.league_go_live;
        if (liveSetting) this.set('goLiveSetting', 'production');
        else this.set('goLiveSetting', 'sandbox');
    },
    @on('didInsertElement')
    execute(){
        const params = this.get("params");
        if (params.token) {
            console.log(params);
            debugger;
            this.set('subscriptionProduct', false);
            let result = Payment.submitNonce(this.get('leagueLevel')[0].id, params.token , "execute");
            result.then(response => {
                this._paymentExecuted();
                this.set("paypalLoading", false);
            }).catch(e => {
                if (e.jqXHR.responseJSON && e.jqXHR.responseJSON.errors) {
                  bootbox.alert(I18n.t("generic_error_with_reason", {error: e.jqXHR.responseJSON.errors.join('. ')}));
                } else {
                  bootbox.alert(I18n.t("generic_error"));
                }
                this.set('checkoutState', 'billing-payment');
                this.set('showBilling', true);
              });
        }
    },
    @on('init')
    paypal() {

        var self = this;
        if (!self.get("subscriptionProduct")) {
            self.set("paypalLoading", true);
            loadScript("https://www.paypalobjects.com/api/checkout.js", { scriptTag: true }).then(() => {
                self.set("paypalLoading", false);
                paypal.Button.render({
                    env: self.get('goLiveSetting'),

                    // Show the buyer a 'Pay Now' button in the checkout flow
                    commit: true,
                    // Set up a getter to create a Payment ID using the payments api, on your server side:

                    payment: function() {
                        return new paypal.Promise(function(resolve, reject) {

                            // Make an ajax call to get the Payment ID. This should call your back-end,
                            // which should invoke the PayPal Payment Create api to retrieve the Payment ID.

                            // When you have a Payment ID, you need to call the `resolve` method, e.g `resolve(data.paymentID)`
                            // Or, if you have an error from your server side, you need to call `reject`, e.g. `reject(err)`
                            // debugger;
                            let result = Payment.submitNonce(self.get('leagueLevel')[0].id, null, false);
                            result.then(response => {
                                let id = response.table.id;
                                if (!id) reject(response);
                                else {
                                    id = id.replace(/"/g,"");
                                    resolve(id);
                                }

                            }).catch(e => {
                                if (e.jqXHR.responseJSON && e.jqXHR.responseJSON.errors) {
                                  bootbox.alert(I18n.t("generic_error_with_reason", {error: e.jqXHR.responseJSON.errors.join('. ')}));
                                } else {
                                  bootbox.alert(I18n.t("generic_error"));
                                }
                                self.set('checkoutState', 'billing-payment');
                                self.set('showBilling', true);
                              });
                        });
                    },

                    // Pass a function to be called when the customer approves the payment,
                    // then call execute payment on your server:

                    onAuthorize: function(data) {

                        // At this point, the payment has been authorized, and you will need to call your back-end to complete the
                        // payment. Your back-end should invoke the PayPal Payment Execute api to finalize the transaction.
                        let result = Payment.submitNonce(self.get('leagueLevel')[0].id, { paymentID: data.paymentID, payerID: data.payerID }, "execute");
                        debugger;
                        result.then(response => {
                            self._paymentExecuted();
                        }).catch(e => {
                            if (e.jqXHR.responseJSON && e.jqXHR.responseJSON.errors) {
                              bootbox.alert(I18n.t("generic_error_with_reason", {error: e.jqXHR.responseJSON.errors.join('. ')}));
                            } else {
                              bootbox.alert(I18n.t("generic_error"));
                            }
                            self.set('checkoutState', 'billing-payment');
                            self.set('showBilling', true);
                          });
                    },

                    // Pass a function to be called when the customer cancels the payment

                    onCancel: function(data) {
                        bootbox.alert(I18n.t("league.checkout.cancel_message"));
                    }

                }, '#paypal-button-container');
            });
        }


    },
    _paymentExecuted(){
        this.set("showCompleted", true);
        this.set('checkoutState', 'completed');
        this.set('showPaypal', false);
    },
    actions: {
        submitPayment(){
            this.set("paypalLoading", true);

                let result = Payment.submitNonce(this.get('leagueLevel')[0].id, null, false);
                result.then(response => {
                    this.set("paypalLoading", false);
                    bootbox.alert("Please wait while you're redirected to Paypal.");
                    document.location = response.table.links[0].table.href;

                }).catch(e => {
                    if (e.jqXHR.responseJSON && e.jqXHR.responseJSON.errors) {
                      bootbox.alert(I18n.t("generic_error_with_reason", {error: e.jqXHR.responseJSON.errors.join('. ')}));
                    } else {
                      bootbox.alert(I18n.t("generic_error"));
                    }
                    this.set('checkoutState', 'billing-payment');
                    this.set('showBilling', true);
                  });
            }
    }

});
