package Sitegen::Controller::Arenda;
use Mojo::Base 'Mojolicious::Controller';

sub rentals(){
	my $self = shift;
	my $config = $self->config;
	my $url = $self->param('url'); 
	my $path = $config->{'downloads'}.'arenda/';

	my @files = glob ($path."$url-*.*");
	foreach my $file (@files){
        $file =~s /$path//;
    };

	my $media = \@files;

	$self->render(
		layout => $config->{'sitename'},
		template => $config->{'sitename'}.'/rentals',
		format => 'html',
		url => $url,
		page => {'url' => $url},
		media => $media,
	);
};

1;
