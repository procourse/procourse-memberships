import GuildPage from '../models/page';
import DiscourseURL from 'discourse/lib/url';

export default Discourse.Route.extend({
  model(opts) {
  	return GuildPage.findById(opts);
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  },

  afterModel: function(result) {
  	var newURL = `/guild/p/${result.slug}/${result.id}/`;
    DiscourseURL.routeTo(newURL, { replaceURL: true });
  }
});