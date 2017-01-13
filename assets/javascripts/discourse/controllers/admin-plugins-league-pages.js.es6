import LeaguePage from '../models/league-page';

export default Ember.Controller.extend({

  pageURL: document.location.origin + "/league/p/",

  baseDLPage: function() {
    var a = [];
    a.set('title', I18n.t('admin.league.pages.new_title'));
    a.set('active', false);
    return a;
  }.property('model.@each.id'),

  removeSelected: function() {
    this.get('model').removeObject(this.get('selectedItem'));
    this.set('selectedItem', null);
  },

  changed: function(){
    if (!this.get('originals') || !this.get('selectedItem')) {this.set('disableSave', true); return;}
    if (((this.get('originals').title == this.get('selectedItem').title) &&
      (this.get('originals').slug == this.get('selectedItem').slug) &&
      (this.get('originals').raw == this.get('selectedItem').raw) &&
      (this.get('originals').cooked == this.get('selectedItem').cooked)) ||
      (!this.get('selectedItem').title) ||
      (!this.get('selectedItem').raw)
      ) {
        this.set('disableSave', true); 
        return;
      }
      else{
        this.set('disableSave', false);
      }
  }.observes('selectedItem.title', 'selectedItem.slug', 'selectedItem.raw'),

  actions: {
    selectDLPage: function(leaguePage) {
      if (this.get('selectedItem')) { this.get('selectedItem').set('selected', false); };
      this.set('originals', {
        title: leaguePage.title,
        active: leaguePage.active,
        slug: leaguePage.slug,
        raw: leaguePage.raw,
        cooked: leaguePage.cooked
      });
      this.set('disableSave', true);
      this.set('selectedItem', leaguePage);
      leaguePage.set('savingStatus', null);
      leaguePage.set('selected', true);
    },

    newDLPage: function() {
      const newDLPage = Em.copy(this.get('baseDLPage'), true);
      newDLPage.set('title', I18n.t('admin.league.pages.new_title'));
      this.get('model').pushObject(newDLPage);
      this.send('selectDLPage', newDLPage);
    },

    toggleEnabled: function() {
      var selectedItem = this.get('selectedItem');
      selectedItem.toggleProperty('active');
      LeaguePage.save(this.get('selectedItem'), true);
    },

    disableEnable: function() {
      return !this.get('id') || this.get('saving');
    }.property('id', 'saving'),

    newRecord: function() {
      return (!this.get('id'));
    }.property('id'),

    save: function() {
      LeaguePage.save(this.get('selectedItem'));
    },

    copy: function(leaguePage) {
      var newDLPage = LeaguePage.copy(leaguePage);
      newDLPage.set('title', I18n.t('admin.customize.colors.copy_name_prefix') + ' ' + leaguePage.get('title'));
      this.get('model').pushObject(newDLPage);
      this.send('selectDLPage', newDLPage);
    },

    destroy: function() {
      var self = this,
          item = self.get('selectedItem');

      return bootbox.confirm(I18n.t("admin.league.pages.delete_confirm"), I18n.t("no_value"), I18n.t("yes_value"), function(result) {
        if (result) {
          if (item.get('newRecord')) {
            self.removeSelected();
          } else {
            LeaguePage.destroy(self.get('selectedItem')).then(function(){ self.removeSelected(); });
          }
        }
      });
    }
  }
});