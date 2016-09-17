package Sitegen::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Upload;

sub dashboard {
	my $self = shift;

	$self->render(msg => 'Welcome to admin dashboard');
}

sub upload {
	my $self = shift;
	my $upload = Mojo::Upload->new;
	say $upload;

	$self->render(data => $upload);
}

sub export {
	my $self = shift;
	my $config = $self->config;


	my $dbi = DBIx::Custom->connect(
		dsn => "dbi:mysql:database=$config->{'dbase'}",
		user => $config->{'user'},
		password => $config->{'pass'},
		option => {mysql_enable_utf8 => 1}
	);

 	my $pages = $dbi->select(
 		table => 'site',

 	)->fetch_hash_all;


	$self->render(pages => $pages, format => 'csv');
}

1;
