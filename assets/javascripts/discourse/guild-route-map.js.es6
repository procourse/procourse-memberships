export default function(){
	this.route('guild', function(){
		this.route('level', {path: '/l' }, function(){
			this.route('show', {path: '/:level'});
		});
	});
};