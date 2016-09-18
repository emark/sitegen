package Sitegen;
use Mojo::Base 'Mojolicious';
use DBIx::Custom;

# This method will run once at server start
sub startup {
	my $self = shift;
	my $config = $self->plugin('Config');
	
	# Router
	my $r = $self->routes;

	$r->get('/admin')->to('admin#dashboard');
	$r->post('/admin/export')->to('admin#export');
	$r->post('/admin/upload')->to('admin#upload');
	
	# Normal route to controller
	$r->get('/:url')->to('generate#page');
}

1;
