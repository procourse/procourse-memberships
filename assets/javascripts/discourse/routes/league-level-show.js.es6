import LeagueLevel from '../models/level';

export default Discourse.Route.extend({
  model(opts) {
  	return LeagueLevel.findById(opts.id);
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});