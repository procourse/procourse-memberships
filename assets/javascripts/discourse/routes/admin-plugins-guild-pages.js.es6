import GuildPage from '../models/guild-page';

export default Discourse.Route.extend({
  model() {
    return GuildPage.findAll();
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});