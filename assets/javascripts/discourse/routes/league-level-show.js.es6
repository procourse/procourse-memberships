import LeagueLevel from '../models/level';

export default Discourse.Route.extend({
  model(opts) {
  	return LeagueLevel.findById(opts.id);
  },

  setupController(controller, model) {
    var group = $.grep(this.currentUser.groups, function(group){ return group.id == parseInt(model[0].group); });
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
    controller.setProperties({ model, memberExists: memberExists, memberSubscription: memberSubscription, showPayment: showPayment });
  }
});