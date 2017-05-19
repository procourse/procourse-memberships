import { ajax } from 'discourse/lib/ajax';

export default {
  clientToken() {
    return ajax('/league/checkout/braintree-token', {dataType: "text"});
  }
};