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
	$r->get('/admin/edit/')->to('admin#edit');
	$r->post('/admin/upload/')->to('admin#upload');
	$r->post('/admin/import/')->to('admin#import');
	$r->post('/admin/update/')->to('admin#update');
	$r->post('/admin/p/add/')->to('admin#add');
	$r->post('/admin/p/delete/')->to('admin#delete');
	$r->get('/admin/p/view/')->to('admin#view');
	$r->post('/admin/p/save/')->to('admin#save');
	
	# Routes to dynamic pages
	$r->get('/allphotos' => [format => ['html']])->to('photo#album');

	# Routes to static pages
	$r->get('/sitemap' => [format => ['xml']])->to('generate#sitemap');
	$r->get('/:url' => [format => ['html']])->to('generate#page');

	#Routes for rentals dynamic pages
	$r->get('/arenda/:url' => [url =>qr/\d\-\d+/], [format => ['html']])->to('arenda#rentals');
	
}

1;
