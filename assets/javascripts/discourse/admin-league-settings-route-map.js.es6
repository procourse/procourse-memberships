export default {
  resource: 'admin.adminPlugins.league',
  path: '/league',
  map() {
  	this.route('index', {path: '/'});
  	this.route('levels');
  	this.route('pages');
  	this.route('payment');
  	this.route('messages');
  	this.route('advanced');
    this.route('extras');
  }
};