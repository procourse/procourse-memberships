export default {
  resource: 'admin.adminPlugins',
  path: '/plugins',
  map() {
    this.route('league', function(){
      this.route('index', {path: '/'});
      this.route('levels');
      this.route('pages');
      this.route('payment');
      this.route('messages');
      this.route('advanced');
      this.route('extras');
    });
  }
};