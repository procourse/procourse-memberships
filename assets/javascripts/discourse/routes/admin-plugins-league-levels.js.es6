import LeagueLevel from '../models/league-level';

export default Discourse.Route.extend({
  model() {
    return LeagueLevel.findAll();
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});