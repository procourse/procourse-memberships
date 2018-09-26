export default function(){
	this.route('league', function(){
		this.route('level', {path: '/l' }, function(){
			this.route('show', {path: '/:id'}, function(){
        this.route('verify', {path: '/verify'});
        this.route('thanks', {path: '/thank-you'})
      });
		});
    this .route('transactions', {path: '/transactions'}, function(){
      this.route('show', {path: '/:user_id/:id'});
    });

    this .route('subscriptions', {path: '/subscriptions'}, function(){
      this.route('show', {path: '/:user_id/:id'});
    });
	});
};
