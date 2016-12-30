import Level from '../models/level';

export default Discourse.Route.extend({
  model() {
    return Level.findAll().then((result) => {
      return result.levels;
    });
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});