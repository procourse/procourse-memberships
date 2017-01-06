import GuildLevel from '../models/guild-level';
import Group from 'discourse/models/group';

export default Ember.Controller.extend({

  levelURL: document.location.origin + "/guild/l/",

  baseDGLevel: function() {
    var a = [];
    a.set('name', I18n.t('admin.guild.levels.new_name'));
    a.set('enabled', false);
    return a;
  }.property('model.@each.id'),

  removeSelected: function() {
    this.get('model').removeObject(this.get('selectedItem'));
    this.set('selectedItem', null);
  },

  changed: function(){
    if (!this.get('originals')) {this.set('disableSave', true); return;}
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
    selectDGLevel: function(dgLevel) {
      GuildLevel.customGroups().then(g => {
        this.set('customGroups', g);
        if (this.get('selectedItem')) { this.get('selectedItem').set('selected', false); };
        this.set('originals', {
          name: dgLevel.name,
          enabled: dgLevel.enabled,
          group: dgLevel.group,
          initial_payment: dgLevel.initial_payment,
          recurring: dgLevel.recurring,
          recurring_payment: dgLevel.recurring_payment,
          trial: dgLevel.trial,
          trial_period: dgLevel.trial_period
        });
        this.set('disableSave', true);
        this.set('selectedItem', dgLevel);
        dgLevel.set('savingStatus', null);
        dgLevel.set('selected', true);
      });
    },

    newDGLevel: function() {
      const newDGLevel = Em.copy(this.get('baseDGLevel'), true);
      newDGLevel.set('name', I18n.t('admin.guild.levels.new_name'));
      this.get('model').pushObject(newDGLevel);
      this.send('selectDGLevel', newDGLevel);
    },

    toggleEnabled: function() {
      var selectedItem = this.get('selectedItem');
      selectedItem.toggleProperty('enabled');
      GuildLevel.save(this.get('selectedItem'), true);
    },

    disableEnable: function() {
      return !this.get('id') || this.get('saving');
    }.property('id', 'saving'),

    newRecord: function() {
      return (!this.get('id'));
    }.property('id'),

    save: function() {
      GuildLevel.save(this.get('selectedItem'));
    },

    copy: function(dgLevel) {
      var newDGLevel = GuildLevel.copy(dgLevel);
      newDGLevel.set('name', I18n.t('admin.customize.colors.copy_name_prefix') + ' ' + dgLevel.get('name'));
      this.get('model').pushObject(newDGLevel);
      this.send('selectDGLevel', newDGLevel);
    },

    destroy: function() {
      var self = this,
          item = self.get('selectedItem');

      return bootbox.confirm(I18n.t("admin.customize.colors.delete_confirm"), I18n.t("no_value"), I18n.t("yes_value"), function(result) {
        if (result) {
          if (item.get('newRecord')) {
            self.removeSelected();
          } else {
            GuildLevel.destroy(self.get('selectedItem')).then(function(){ self.removeSelected(); });
          }
        }
      });
    }
  }
});