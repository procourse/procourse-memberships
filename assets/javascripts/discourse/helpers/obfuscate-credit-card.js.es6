import { registerUnbound } from 'discourse-common/lib/helpers';

registerUnbound('obfuscate-credit-card', function(val) {
  var newNumber = "xxxxxxxxxxxx" + val.substr(-4);
  return newNumber;
});