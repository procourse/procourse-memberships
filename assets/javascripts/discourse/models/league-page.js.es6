import { ajax } from 'discourse/lib/ajax';
import { default as PrettyText, buildOptions } from 'pretty-text/pretty-text';

const LeaguePage = Discourse.Model.extend(Ember.Copyable, {

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


var LeaguePages = Ember.ArrayProxy.extend({
  selectedItemChanged: function() {
    var selected = this.get('selectedItem');
    _.each(this.get('content'),function(i) {
      return i.set('selected', selected === i);
    });
  }.observes('selectedItem')
});

LeaguePage.reopenClass({

  findAll: function() {
    var leaguePages = LeaguePages.create({ content: [], loading: true });
    ajax('/league/admin/pages.json').then(function(pages) {
      if (pages){
        _.each(pages, function(leaguePage){
            leaguePages.pushObject(LeaguePage.create({
            id: leaguePage.id,
            title: leaguePage.title,
            active: leaguePage.active,
            slug: leaguePage.slug,
            raw: leaguePage.raw,
            cooked: leaguePage.cooked,
            custom_slug: leaguePage.custom_slug
          }));
        });
      };
      leaguePages.set('loading', false);
    });
    return leaguePages;
  },

  save: function(object, enabledOnly=false) {
    if (object.get('disableSave')) return;
    
    object.set('savingStatus', I18n.t('saving'));
    object.set('saving',true);

    var data = { active: object.active };

    if (object.id){
      data.id = object.id;
    }

    if (!object || !enabledOnly) {
      var cooked = new Handlebars.SafeString(new PrettyText(getOpts()).cook(object.raw));
      data.title = object.title;
      data.slug = object.slug;
      data.raw = object.raw;
      data.cooked = cooked.string;
      data.custom_slug = object.custom_slug;
    };
    
    return ajax("/league/admin/pages.json", {
      data: JSON.stringify({"league_page": data}),
      type: object.id ? 'PUT' : 'POST',
      dataType: 'json',
      contentType: 'application/json'
    }).then(function(result) {
      if(result.id) { object.set('id', result.id); }
      object.set('savingStatus', I18n.t('saved'));
      object.set('saving', false);
    });
  },

  copy: function(object){
    var copiedPage = LeaguePage.create(object);
    copiedPage.id = null;
    return copiedPage;
  },

  destroy: function(object) {
    if (object.id) {
      var data = { id: object.id };
      return ajax("/league/admin/pages.json", { 
        data: JSON.stringify({"league_page": data }), 
        type: 'DELETE',
        dataType: 'json',
        contentType: 'application/json' });
    }
  }
});

export default LeaguePage;