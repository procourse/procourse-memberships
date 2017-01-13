import LeagueLevel from '../models/league-level';
import Group from 'discourse/models/group';

export default Ember.Controller.extend({

  levelURL: document.location.origin + "/league/l/",

  baseDLLevel: function() {
    var a = [];
    a.set('name', I18n.t('admin.league.levels.new_name'));
    a.set('enabled', false);
    return a;
  }.property('model.@each.id'),

  removeSelected: function() {
    this.get('model').removeObject(this.get('selectedItem'));
    this.set('selectedItem', null);
  },

  changed: function(){
    if (!this.get('originals') || !this.get('selectedItem')) {this.set('disableSave', true); return;}
    if (((this.get('originals').name == this.get('selectedItem').name) &&
      (this.get('originals').group == this.get('selectedItem').group) &&
      (this.get('originals').initial_payment == this.get('selectedItem').initial_payment) &&
      (this.get('originals').recurring == this.get('selectedItem').recurring) &&
      (this.get('originals').recurring_payment == this.get('selectedItem').recurring_payment) &&
      (this.get('originals').trial == this.get('selectedItem').trial) &&
      (this.get('originals').trial_period == this.get('selectedItem').trial_period)) ||
      (!this.get('selectedItem').group) ||
      (!this.get('selectedItem').name) ||
      ((this.get('selectedItem').initial_payment == 0) && (this.get('selectedItem').recurring == false))
      ) {
        this.set('disableSave', true); 
        return;
      }
      else{
        this.set('disableSave', false);
      }
  }.observes('selectedItem.name', 'selectedItem.group', 'selectedItem.initial_payment', 
    'selectedItem.recurring', 'selectedItem.recurring_payment', 'selectedItem.trial', 'selectedItem.trial_period'),

  actions: {
    selectDLLevel: function(leagueLevel) {
      LeagueLevel.customGroups().then(g => {
        this.set('customGroups', g);
        if (this.get('selectedItem')) { this.get('selectedItem').set('selected', false); };
        this.set('originals', {
          name: leagueLevel.name,
          enabled: leagueLevel.enabled,
          group: leagueLevel.group,
          initial_payment: leagueLevel.initial_payment,
          recurring: leagueLevel.recurring,
          recurring_payment: leagueLevel.recurring_payment,
          trial: leagueLevel.trial,
          trial_period: leagueLevel.trial_period
        });
        this.set('disableSave', true);
        this.set('selectedItem', leagueLevel);
        leagueLevel.set('savingStatus', null);
        leagueLevel.set('selected', true);
      });
    },

    newDLLevel: function() {
      const newDLLevel = Em.copy(this.get('baseDLLevel'), true);
      newDLLevel.set('name', I18n.t('admin.league.levels.new_name'));
      this.get('model').pushObject(newDLLevel);
      this.send('selectDLLevel', newDLLevel);
    },

    toggleEnabled: function() {
      var selectedItem = this.get('selectedItem');
      selectedItem.toggleProperty('enabled');
      LeagueLevel.save(this.get('selectedItem'), true);
    },

    disableEnable: function() {
      return !this.get('id') || this.get('saving');
    }.property('id', 'saving'),

    newRecord: function() {
      return (!this.get('id'));
    }.property('id'),

    save: function() {
      LeagueLevel.save(this.get('selectedItem'));
    },

    copy: function(leagueLevel) {
      var newDLLevel = LeagueLevel.copy(leagueLevel);
      newDLLevel.set('name', I18n.t('admin.customize.colors.copy_name_prefix') + ' ' + leagueLevel.get('name'));
      this.get('model').pushObject(newDLLevel);
      this.send('selectDLLevel', newDLLevel);
    },

    destroy: function() {
      var self = this,
          item = self.get('selectedItem');

      return bootbox.confirm(I18n.t("admin.league.levels.delete_confirm"), I18n.t("no_value"), I18n.t("yes_value"), function(result) {
        if (result) {
          if (item.get('newRecord')) {
            self.removeSelected();
          } else {
            LeagueLevel.destroy(self.get('selectedItem')).then(function(){ self.removeSelected(); });
          }
        }
      });
    }
  }
});