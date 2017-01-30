import LeagueGateway from '../models/league-gateway';

export default Discourse.Route.extend({
  model() {
    return;
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});