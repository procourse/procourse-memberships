import GuildLevel from '../models/guild-level';

export default Discourse.Route.extend({
  model() {
    return GuildLevel.findAll();
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});