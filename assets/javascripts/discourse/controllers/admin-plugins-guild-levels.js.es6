import GuildLevel from '../models/guild-level';

export default Ember.Controller.extend({

  baseDGLevel: function() {
    var a = [];
    a.set('name', I18n.t('admin.guild.levels.new_name'));
    a.set('enabled', false);
    return a;
  }.property('model.@each.id'),

  removeSelected() {
    this.get('model').removeObject(this.get('selectedItem'));
    this.set('selectedItem', null);
  },

  actions: {
    selectDGLevel: function(dgLevel) {
        if (this.get('selectedItem')) { this.get('selectedItem').set('selected', false); }
        this.set('selectedItem', dgLevel);
        dgLevel.set('savingStatus', null);
        dgLevel.set('selected', true);
      },

      newDGLevel() {
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

      save: function() {
        GuildLevel.save(this.get('selectedItem'));
      },

      copy(dgLevel) {
        var newDGLevel = Em.copy(dgLevel, true);
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