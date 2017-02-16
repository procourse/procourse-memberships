import { registerUnbound } from 'discourse-common/lib/helpers';

registerUnbound('format-currency', function(val) {
  val = val.toString();
  var amount = val.split(".");
  if (amount[1] == undefined){
    amount[1] = "00";
  }
  else{
    amount[1] = (amount[1] + "000").substring(0,2);
  }
  return "$" + amount[0] + "." + amount[1];
});