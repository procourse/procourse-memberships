import Level from 'discourse/plugins/discourse-guild/admin/models/level';

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

	updateEnabled: function() {
		var selectedItem = this.get('selectedItem');
		if (selectedItem.get('enabled')) {
			this.get('model').forEach(function(c) {
				if (c !== selectedItem) {
					c.set('enabled', false);
					c.startTrackingChanges();
					c.notifyPropertyChange('description');
				}
			});
		}
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
	      selectedItem.save({enabledOnly: true});
	      this.updateEnabled();
	    },

	    save: function() {
	      Level.save(this.get('selectedItem'));
	      this.updateEnabled();
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
	            item.destroy().then(function(){ self.removeSelected(); });
	          }
	        }
	      });
	    }
	}
});