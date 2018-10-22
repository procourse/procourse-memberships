import MembershipsLevel from '../models/memberships-level';

export default Discourse.Route.extend({
  model() {
    return MembershipsLevel.findAll();
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});