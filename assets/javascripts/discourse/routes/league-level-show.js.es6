import LeagueLevel from '../models/level';

export default Discourse.Route.extend({
  model(opts) {
  	return LeagueLevel.findById(opts.id);
  },

  setupController(controller, model) {
    if (this.currentUser){
      var group = $.grep(this.currentUser.groups, function(group){ return group.id == parseInt(model[0].group); });  
    }
    else{
      var group = [];
    }

    if (group.length > 0){
      var memberExists = true;
    }
    else{
      var memberExists = false;
    }

    if (model[0].user_subscribed){
      var memberSubscription = true;
    }
    else{
      var memberSubscription = false;
    }

    if (!memberExists){
      var showPayment = true;
    }
    else if (memberExists && memberSubscription){
      var showPayment = true;
    }
    else if (memberExists && !memberSubscription){
      var showPayment = false;
    }
    else{
      var showPayment = false;
    };

    if (model[0].user_insufficient_tl){
      var memberInsufficientTL = true;
      var showPayment = false;
    }
    else{
      var memberInsufficientTL = false;
    }

    controller.setProperties({ model, memberExists: memberExists, memberSubscription: memberSubscription, memberInsufficientTL: memberInsufficientTL, showPayment: showPayment });
  }
});