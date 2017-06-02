import { ajax } from 'discourse/lib/ajax';

export default {
  submitNonce(level_id, nonce, update) {
    return ajax('/league/checkout/submit-payment', {
      data: JSON.stringify({"level_id": level_id, "nonce": nonce, "update": update}),
      type: 'POST',
      dataType: 'json',
      contentType: 'application/json'
    })
  }
};