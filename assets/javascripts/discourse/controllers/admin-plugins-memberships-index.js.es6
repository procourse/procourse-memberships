import Dashboard from '../models/dashboard';

export default Ember.Controller.extend({
  dashboardInit: Dashboard.getDashboard(),

  _init: function() {
    self = this;
    this.get('dashboardInit').then(function(result){
      self.set('dashboard', result.cooked);
    });
  }.on('init'),
})