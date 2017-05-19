import { ajax } from 'discourse/lib/ajax';

export default {
  submitNonce(level_id, nonce) {
    return ajax('/league/checkout/submit-payment', {
      data: JSON.stringify({"level_id": level_id, "nonce": nonce}),
      type: 'POST',
      dataType: 'json',
      contentType: 'application/json'
    })
  }
};