import { ajax } from 'discourse/lib/ajax';
import { default as PrettyText, buildOptions } from 'pretty-text/pretty-text';

const GuildPage = Discourse.Model.extend(Ember.Copyable, {

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


var GuildPages = Ember.ArrayProxy.extend({
  selectedItemChanged: function() {
    var selected = this.get('selectedItem');
    _.each(this.get('content'),function(i) {
      return i.set('selected', selected === i);
    });
  }.observes('selectedItem')
});

GuildPage.reopenClass({

  findAll: function() {
    var guildPages = GuildPages.create({ content: [], loading: true });
    ajax('/guild/pages').then(function(pages) {
      if (pages){
        _.each(pages, function(guildPage){
            guildPages.pushObject(GuildPage.create({
            id: guildPage.id,
            title: guildPage.title,
            active: guildPage.active,
            slug: guildPage.slug,
            raw: guildPage.raw,
            cooked: guildPage.cooked
          }));
        });
      };
      guildPages.set('loading', false);
    });
    return guildPages;
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
    };
    
    return ajax("/guild/admin/pages.json", {
      data: JSON.stringify({"guild_page": data}),
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
    var copiedPage = GuildPage.create(object);
    copiedPage.id = null;
    return copiedPage;
  },

  destroy: function(object) {
    if (object.id) {
      var data = { id: object.id };
      return ajax("/guild/admin/pages.json", { 
        data: JSON.stringify({"guild_page": data }), 
        type: 'DELETE',
        dataType: 'json',
        contentType: 'application/json' });
    }
  }
});

export default GuildPage;