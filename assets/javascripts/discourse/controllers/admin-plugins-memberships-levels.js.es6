import MembershipsLevel from '../models/memberships-level';
import Group from 'discourse/models/group';

export default Ember.Controller.extend({

  levelURL: document.location.origin + "/memberships/l/",

  basePCMLevel: function() {
    var a = [];
    a.set('name', I18n.t('admin.memberships.levels.new_name'));
    a.set('enabled', false);
    a.set('trust_level', 0);
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
      (this.get('originals').trust_level == this.get('selectedItem').trust_level) &&
      (this.get('originals').initial_payment == this.get('selectedItem').initial_payment) &&
      (this.get('originals').recurring == this.get('selectedItem').recurring) &&
      (this.get('originals').recurring_payment == this.get('selectedItem').recurring_payment) &&
      (this.get('originals').recurring_payment_period == this.get('selectedItem').recurring_payment_period) &&
      (this.get('originals').trial == this.get('selectedItem').trial) &&
      (this.get('originals').description_raw == this.get('selectedItem').description_raw) &&
      (this.get('originals').description_cooked == this.get('selectedItem').description_cooked) &&
      (this.get('originals').welcome_message == this.get('selectedItem').welcome_message) &&
      (this.get('originals').braintree_plan_id == this.get('selectedItem').braintree_plan_id) &&
      (this.get('originals').trial_period == this.get('selectedItem').trial_period)) ||
      (!this.get('selectedItem').group) ||
      (!this.get('selectedItem').name) ||
      (this.get('selectedItem.paypal_plan_status') === "ACTIVE") ||
      ((this.get('selectedItem').initial_payment == 0) && (this.get('selectedItem').recurring == false))
      ) {
        this.set('disableSave', true); 
        return;
      }
      else{
        this.set('disableSave', false);
      }
  }.observes('selectedItem.name', 'selectedItem.group', 'selectedItem.trust_level', 'selectedItem.initial_payment', 
    'selectedItem.recurring', 'selectedItem.recurring_payment', 'selectedItem.recurring_payment_period', 
    'selectedItem.trial', 'selectedItem.trial_period', 'selectedItem.description_raw', 'selectedItem.description_cooked', 
    'selectedItem.welcome_message', 'selectedItem.braintree_plan_id'),

  _init: function() {
    var gateway = Discourse.SiteSettings.memberships_gateway;
    if (gateway == "Braintree"){
      this.set('braintree', true);
    };
    this.set('trustLevels', Discourse.Site.current().get('trustLevels'));
  }.on('init'),

  actions: {
    selectPCMLevel: function(membershipsLevel) {
      MembershipsLevel.customGroups().then(g => {
        this.set('customGroups', g);
        if (this.get('selectedItem')) { this.get('selectedItem').set('selected', false); };
        this.set('originals', {
          name: membershipsLevel.name,
          enabled: membershipsLevel.enabled,
          group: membershipsLevel.group,
          trust_level: membershipsLevel.trust_level,
          initial_payment: membershipsLevel.initial_payment,
          recurring: membershipsLevel.recurring,
          recurring_payment: membershipsLevel.recurring_payment,
          trial: membershipsLevel.trial,
          trial_period: membershipsLevel.trial_period,
          description_raw: membershipsLevel.description_raw,
          description_cooked: membershipsLevel.description_cooked,
          welcome_message: membershipsLevel.welcome_message,
          braintree_plan_id: membershipsLevel.braintree_plan_id
        });
        this.set('disableSave', true);
        this.set("paypalSubscriptionActive", false);
        this.set('selectedItem', membershipsLevel);
        if (membershipsLevel.paypal_plan_status === "ACTIVE") this.set("paypalSubscriptionActive", true);
        membershipsLevel.set('savingStatus', null);
        membershipsLevel.set('selected', true);
      });
    },

    newPCMLevel: function() {
      const newPCMLevel = Em.copy(this.get('basePCMLevel'), true);
      newPCMLevel.set('name', I18n.t('admin.memberships.levels.new_name'));
      newPCMLevel.set('newRecord', true);
      this.get('model').pushObject(newPCMLevel);
      this.send('selectPCMLevel', newPCMLevel);
    },

    toggleEnabled: function() {
      var selectedItem = this.get('selectedItem');
      selectedItem.toggleProperty('enabled');
      MembershipsLevel.save(this.get('selectedItem'), true);
    },

    disableEnable: function() {
      return !this.get('id') || this.get('saving');
    }.property('id', 'saving'),

    newRecord: function() {
      return (!this.get('id'));
    }.property('id'),

    save: function() {
      MembershipsLevel.save(this.get('selectedItem'));
    },

    copy: function(MembershipsLevel) {
      var newPCMLevel = MembershipsLevel.copy(MembershipsLevel);
      newPCMLevel.set('name', I18n.t('admin.customize.colors.copy_name_prefix') + ' ' + MembershipsLevel.get('name'));
      this.get('model').pushObject(newPCMLevel);
      this.send('selectPCMLevel', newPCMLevel);
    },

    destroy: function() {
      var self = this,
          item = self.get('selectedItem');

      return bootbox.confirm(I18n.t("admin.memberships.levels.delete_confirm"), I18n.t("no_value"), I18n.t("yes_value"), function(result) {
        if (result) {
          if (!item.id) {
            self.removeSelected();
          } else {
            MembershipsLevel.destroy(self.get('selectedItem')).then(function(){ self.removeSelected(); });
          }
        }
      });
    }
  }
});