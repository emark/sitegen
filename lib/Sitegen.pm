package Sitegen;
use Mojo::Base 'Mojolicious';
use DBIx::Custom;

my $config = '';

has 'dbh' => sub {
	my $self = shift;
	
	my $dbi = DBIx::Custom->connect(
			dsn => $config->{dsn},
			user => $config->{user},
			password => $config->{password},
			option => {mysql_enable_utf8 => 1}
	);
	$dbi->do('SET NAMES utf8');

	return $dbi;
};

# This method will run once at server start
sub startup {
	my $self = shift;
	$config = $self->plugin('Config');
	
	# Router
	my $r = $self->routes;

	$r->get('/admin')->to('admin#dashboard');
	$r->post('/admin/export')->to('admin#export');
	$r->post('/admin/upload')->to('admin#upload');
	
	# Pages routes
	$r->post('/admin/p/add')->to('admin#add');
	$r->post('/admin/p/delete')->to('admin#delete');
	
	# Routes to dynamic pages
	$r->get('/booking')->to('booking#add');
	$r->post('/booking')->to('booking#extended');

	# Routes to static pages
	$r->get('/:url')->to('generate#page');
}

1;
