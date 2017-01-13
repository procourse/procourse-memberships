import LeaguePage from '../models/league-page';

export default Discourse.Route.extend({
  model() {
    return LeaguePage.findAll();
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});