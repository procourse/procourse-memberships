import LeaguePage from '../models/page';
import DiscourseURL from 'discourse/lib/url';

export default Discourse.Route.extend({
  model(opts) {
  	return LeaguePage.findById(opts);
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  },

  afterModel: function(result) {
  	var newURL = `/league/p/${result.slug}/${result.id}/`;
    DiscourseURL.routeTo(newURL, { replaceURL: true });
  }
});