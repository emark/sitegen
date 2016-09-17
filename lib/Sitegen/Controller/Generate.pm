package Sitegen::Controller::Generate;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub page {
	my $self = shift;
	my $config = $self->config;
	my $url = $self->param;

	my $dbi = DBIx::Custom->connect(
		dsn => "dbi:mysql:database=$config->{'dbase'}",
		user => $config->{'user'},
		password => $config->{'pass'},
		option => {mysql_enable_utf8 => 1}
	);

 	my $page = $dbi->select(
 			table => 'site',
 			columns => ['meta','content'],
 			where => {url => $url},
 	
 	)->fetch_hash;


	$self->render(page => $page);
}

1;
