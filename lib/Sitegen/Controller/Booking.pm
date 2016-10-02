package Sitegen::Controller::Booking;
use Mojo::Base 'Mojolicious::Controller';

my $page = {url => 'booking'};

sub extended {
	my $self = shift;
	my $config = $self->config;

	my $dbi = DBIx::Custom->connect(
		dsn => "dbi:mysql:database=$config->{'dbase'}",
		user => $config->{'user'},
		password => $config->{'pass'},
		option => {mysql_enable_utf8 => 1}
	);

	$self->render(
		template => $config->{site}.'/booking', 
		layout => $config->{site},
		page => $page
	);

};

sub add {
	my $self = shift;
	my $config = $self->config;
	
	$self->render(
		template => $config->{site}.'/booking', 
		layout => $config->{site},
		page => $page
	);

};

1;
