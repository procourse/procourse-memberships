export default function(){
	this.route('league', function(){
		this.route('level', {path: '/l' }, function(){
			this.route('show', {path: '/:id'}, function(){
        this.route('verify', {path: '/verify'});
        this.route('thanks', {path: '/thank-you'})
      });
		});
		this.route('page', {path: '/p' }, function(){
			this.route('show', {path: '/:slug/:id'});
		});
    this.route('checkout', {path: '/checkout'}, function(){
      this.route('paypal', {path: '/paypal'}, function(){
        this.route('success', {path: '/success'});
      })
    });
    this .route('transactions', {path: '/transactions'}, function(){
      this.route('show', {path: '/:user_id/:id'});
    });

    this .route('subscriptions', {path: '/subscriptions'}, function(){
      this.route('show', {path: '/:user_id/:id'});
    });
	});
};