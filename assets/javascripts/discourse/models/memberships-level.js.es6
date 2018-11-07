import { ajax } from 'discourse/lib/ajax';
import Group from 'discourse/models/group';
import { default as PrettyText, buildOptions } from 'pretty-text/pretty-text';

const MembershipsLevel = Discourse.Model.extend(Ember.Copyable, {

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

var MembershipsLevels = Ember.ArrayProxy.extend({
  selectedItemChanged: function() {
    var selected = this.get('selectedItem');
    _.each(this.get('content'),function(i) {
      return i.set('selected', selected === i);
    });
  }.observes('selectedItem')
});

MembershipsLevel.reopenClass({
  customGroups: function(){
    return Group.findAll().then(groups => {
      return groups.filter(g => !g.get('automatic'));
    });
  },

  findAll: function() {
    var membershipsLevels = MembershipsLevels.create({ content: [], loading: true });
    ajax('/memberships/admin/levels.json').then(function(levels) {
      if (levels){
        _.each(levels, function(membershipsLevel){
          membershipsLevels.pushObject(MembershipsLevel.create({
            id: membershipsLevel.id,
            name: membershipsLevel.name,
            enabled: membershipsLevel.enabled,
            group: membershipsLevel.group,
            trust_level: membershipsLevel.trust_level,
            initial_payment: membershipsLevel.initial_payment,
            recurring: membershipsLevel.recurring,
            recurring_payment: membershipsLevel.recurring_payment,
            recurring_payment_period: membershipsLevel.recurring_payment_period,
            trial: membershipsLevel.trial,
            trial_period: membershipsLevel.trial_period,
            description_raw: membershipsLevel.description_raw,
            description_cooked: membershipsLevel.description_cooked,
            welcome_message: membershipsLevel.welcome_message,
            braintree_plan_id: membershipsLevel.braintree_plan_id,
            paypal_plan_status: membershipsLevel.paypal_plan_status,
            stripe_plan_id: membershipsLevel.stripe_plan_id
          }));
        });
      };
      membershipsLevels.set('loading', false);
    });
    return membershipsLevels;
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
      data.trust_level = self.trust_level || 0;
      data.initial_payment = self.initial_payment;
      data.recurring = self.recurring;
      data.recurring_payment = self.recurring_payment;
      data.recurring_payment_period = self.recurring_payment_period;
      data.trial = self.trial;
      data.trial_period = self.trial_period;
      data.description_raw = self.description_raw;
      data.description_cooked = cooked.string;
      data.welcome_message = self.welcome_message;
      data.braintree_plan_id = self.braintree_plan_id;
    };

    return ajax("/memberships/admin/levels.json", {
      data: JSON.stringify({"memberships_level": data}),
      type: self.id ? 'PUT' : 'POST',
      dataType: 'json',
      contentType: 'application/json'
    }).then(function(result) {
      if (result.errors){
        bootbox.alert(result.errors);
        self.set('saving', false);
      }
      if(result.id) { self.set('id', result.id); }
      self.set('savingStatus', I18n.t('saved'));
      self.set('saving', false);
    });
  },

  copy: function(object){
    var copiedLevel = MembershipsLevel.create(object);
    copiedLevel.id = null;
    return copiedLevel;
  },

  destroy: function(object) {
    if (object.id) {
      var data = { id: object.id };
      return ajax("/memberships/admin/levels.json", {
        data: JSON.stringify({"memberships_level": data }),
        type: 'DELETE',
        dataType: 'json',
        contentType: 'application/json' });
    }
  }
});

export default MembershipsLevel;
