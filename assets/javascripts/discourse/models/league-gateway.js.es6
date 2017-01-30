import { ajax } from 'discourse/lib/ajax';

const LeagueGateway = Discourse.Model.extend(Ember.Copyable, {

  init: function() {
    this._super();
  }
});

var LeagueGateways = Ember.ArrayProxy;

LeagueGateway.reopenClass({

  findAll: function() {
    var leagueGateways = LeagueGateways.create({ content: [], loading: true });
    ajax('/league/admin/gateways').then(function(gateways) {
      if (gateways){
        _.each(gateways, function(leagueGateway, key){
            leagueGateways.pushObject({"id": key, "name": leagueGateway.name});
        });
      };
      leagueGateways.set('loading', false);
    });
    return leagueGateways;
  },

  save: function(object, enabledOnly=false) {
  }
});

export default LeagueGateway;