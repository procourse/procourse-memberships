import { ajax } from 'discourse/lib/ajax';

export default {
  logPayPalSuccess(token, payerid, productid) {
    self = this;
    ajax('/memberships/checkout/paypal/success', {
      data: JSON.stringify({"token": token, "payerID": payerid, "productID": productid}),
      type: 'POST',
      dataType: 'json',
      contentType: 'application/json'
    }).then(function(result){
      console.log(result);
      self.set('paypalResult', result);
    });
  }
};