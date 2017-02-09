import { ajax } from 'discourse/lib/ajax';
import Group from 'discourse/models/group';
import { default as PrettyText, buildOptions } from 'pretty-text/pretty-text';

const LeagueLevel = Discourse.Model.extend(Ember.Copyable, {

  init: function() {
    this._super();
  }
});

function getOpts() {
  const siteSettings = Discourse.__container__.lookup('site-settings:main');

  return buildOptions({
    getURL: Discourse.getURLWithCDN,
    currentUser: Discourse.__container__.lookup('current-user:main'),
    siteSettings
  });
}

var LeagueLevels = Ember.ArrayProxy.extend({
  selectedItemChanged: function() {
    var selected = this.get('selectedItem');
    _.each(this.get('content'),function(i) {
      return i.set('selected', selected === i);
    });
  }.observes('selectedItem')
});

LeagueLevel.reopenClass({
  customGroups: function(){
    return Group.findAll().then(groups => {
      return groups.filter(g => !g.get('automatic'));
    });
  },

  findAll: function() {
    var leagueLevels = LeagueLevels.create({ content: [], loading: true });
    ajax('/league/admin/levels.json').then(function(levels) {
      if (levels){
        _.each(levels, function(leagueLevel){
            leagueLevels.pushObject(LeagueLevel.create({
            id: leagueLevel.id,
            name: leagueLevel.name,
            enabled: leagueLevel.enabled,
            group: leagueLevel.group,
            initial_payment: leagueLevel.initial_payment,
            recurring: leagueLevel.recurring,
            recurring_payment: leagueLevel.recurring_payment,
            recurring_payment_period: leagueLevel.recurring_payment_period,
            trial: leagueLevel.trial,
            trial_period: leagueLevel.trial_period,
            description_raw: leagueLevel.description_raw,
            description_cooked: leagueLevel.description_cooked
          }));
        });
      };
      leagueLevels.set('loading', false);
    });
    return leagueLevels;
  },

  save: function(object, enabledOnly=false) {
    if (object.get('disableSave')) return;
    
    var self = object;
    self.set('savingStatus', I18n.t('saving'));
    self.set('saving',true);

    var data = { enabled: self.enabled };

    if (self.id){
      data.id = self.id;
    }

    if (!object || !enabledOnly) {
      var cooked = new Handlebars.SafeString(new PrettyText(getOpts()).cook(object.description_raw));
      data.name = self.name;
      data.group = self.group;
      data.initial_payment = self.initial_payment;
      data.recurring = self.recurring;
      data.recurring_payment = self.recurring_payment;
      data.recurring_payment_period = self.recurring_payment_period;
      data.trial = self.trial;
      data.trial_period = self.trial_period;
      data.description_raw = self.description_raw;
      data.description_cooked = cooked.string;
    };

    return ajax("/league/admin/levels.json", {
      data: JSON.stringify({"league_level": data}),
      type: self.id ? 'PUT' : 'POST',
      dataType: 'json',
      contentType: 'application/json'
    }).then(function(result) {
      if(result.id) { self.set('id', result.id); }
      self.set('savingStatus', I18n.t('saved'));
      self.set('saving', false);
    });
  },

  copy: function(object){
    var copiedLevel = LeagueLevel.create(object);
    copiedLevel.id = null;
    return copiedLevel;
  },

  destroy: function(object) {
    if (object.id) {
      var data = { id: object.id };
      return ajax("/league/admin/levels.json", { 
        data: JSON.stringify({"league_level": data }), 
        type: 'DELETE',
        dataType: 'json',
        contentType: 'application/json' });
    }
  }
});

export default LeagueLevel;