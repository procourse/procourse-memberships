export default {
  resource: 'admin.adminPlugins',
  path: '/plugins',
  map() {
    this.route('memberships', function(){
      this.route('index', {path: '/'});
      this.route('levels');
      this.route('pages');
      this.route('gateways');
      this.route('messages');
      this.route('advanced');
      this.route('extras');
    });
  }
};