export default Discourse.Route.extend({
  model() {
    return Discourse.User.current();
  },

  setupController(controller, model) {
    controller.setProperties({ model });
  }
});