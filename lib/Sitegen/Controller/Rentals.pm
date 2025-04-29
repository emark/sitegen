package Sitegen::Controller::Rentals;
use Mojo::Base 'Mojolicious::Controller';

sub show(){
	my $self = shift;
	my $config = $self->config;
	my $url = 'rentals/'.$self->param('url');
	my $room = $self->param('url');
	my $path = $config->{'downloads'}.'rentals/';

	my @files = glob ($path."$room-*.*");
	foreach my $file (@files){
        $file =~s /$path//;
    };

	my $media = \@files;

	$self->render(
		layout => $config->{'sitename'},
		template => $config->{'sitename'}.'/rentals',
		format => 'html',
		url => $url,
		room => $room,
		page => {'url' => $url},
		media => $media,
	);
};

1;
