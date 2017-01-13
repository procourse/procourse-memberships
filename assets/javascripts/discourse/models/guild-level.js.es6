import { ajax } from 'discourse/lib/ajax';
import Group from 'discourse/models/group';

const GuildLevel = Discourse.Model.extend(Ember.Copyable, {

  init: function() {
    this._super();
  }
});

var GuildLevels = Ember.ArrayProxy.extend({
  selectedItemChanged: function() {
    var selected = this.get('selectedItem');
    _.each(this.get('content'),function(i) {
      return i.set('selected', selected === i);
    });
  }.observes('selectedItem')
});

GuildLevel.reopenClass({
  customGroups: function(){
    return Group.findAll().then(groups => {
      return groups.filter(g => !g.get('automatic'));
    });
  },

  findAll: function() {
    var guildLevels = GuildLevels.create({ content: [], loading: true });
    ajax('/guild/levels').then(function(levels) {
      if (levels){
        _.each(levels, function(guildLevel){
            guildLevels.pushObject(GuildLevel.create({
            id: guildLevel.id,
            name: guildLevel.name,
            enabled: guildLevel.enabled,
            group: guildLevel.group,
            initial_payment: guildLevel.initial_payment,
            recurring: guildLevel.recurring,
            recurring_payment: guildLevel.recurring_payment,
            trial: guildLevel.trial,
            trial_period: guildLevel.trial_period
          }));
        });
      };
      guildLevels.set('loading', false);
    });
    return guildLevels;
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
      data.name = self.name;
      data.group = self.group;
      data.initial_payment = self.initial_payment;
      data.recurring = self.recurring;
      data.recurring_payment = self.recurring_payment;
      data.trial = self.trial;
      data.trial_period = self.trial_period;
    };

    return ajax("/guild/admin/levels.json", {
      data: JSON.stringify({"guild_level": data}),
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
    var copiedLevel = GuildLevel.create(object);
    copiedLevel.id = null;
    return copiedLevel;
  },

  destroy: function(object) {
    if (object.id) {
      var data = { id: object.id };
      return ajax("/guild/admin/levels.json", { 
        data: JSON.stringify({"guild_level": data }), 
        type: 'DELETE',
        dataType: 'json',
        contentType: 'application/json' });
    }
  }
});

export default GuildLevel;