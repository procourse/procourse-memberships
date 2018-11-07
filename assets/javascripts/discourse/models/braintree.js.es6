import { ajax } from 'discourse/lib/ajax';

export default {
  clientToken() {
    return ajax('/memberships/checkout/braintree-token', {dataType: "text"});
  }
};