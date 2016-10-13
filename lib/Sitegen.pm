package Sitegen;
use Mojo::Base 'Mojolicious';
use DBIx::Custom;

my $config = '';

has 'dbh' => sub {
	my $self = shift;
	
	my $dbi = DBIx::Custom->connect(
			dsn => $config->{dsn},
			user => $config->{dbuser},
			password => $config->{dbpassword},
			option => {mysql_enable_utf8 => 1}
	);

	return $dbi;
};

# This method will run once at server start
sub startup {
	my $self = shift;
	$config = $self->plugin('Config');
	$self->mode($config->{mode});
	$self->secrets([$config->{secrets}]);	

	my $r = $self->routes;
	
	#Administrative
	$r->any('/admin/')->to('admin#auth');
	$r->any('/admin/logout/')->to('admin#logout');
	$r->get('/admin/dashboard/')->to('admin#dashboard');
	$r->post('/admin/export/')->to('admin#export');
	$r->post('/admin/upload/')->to('admin#upload');
	$r->post('/admin/p/add')->to('admin#add');
	$r->post('/admin/p/delete')->to('admin#delete');
	
	# Routes to dynamic pages
	$r->get('/booking')->to('booking#add');
	$r->post('/booking')->to('booking#extended');

	# Routes to static pages
	$r->get('/sitemap')->to('generate#sitemap');
	$r->get('/:url')->to('generate#page');

}

1;
