package Sitegen::Controller::Photo;
use Mojo::Base 'Mojolicious::Controller';

sub album {
	my $self = shift;
	my $config = $self->config;

	my %album = ();
	my %photo = ();
 	my $pages = $self->app->dbh->select(
 			table =>$config->{prefix}.$config->{sitename},
 			columns => ['url','meta','content'],
 	
 	)->fetch_hash_all || 0;

	foreach my $page (@{$pages}){
		my %meta = ();
		foreach my $meta (split('%',$page->{meta})){
			my ($key,$value) = split(':',$meta);
			$meta{$key}= $value;

		};

		if($meta{template} && $meta{template} eq 'products'){
			my %content = ();
			foreach my $content (split('%',$page->{content})){
				my ($key,$value) = split(':',$content);
				$content{$key}= $value;

			};

			$album{$page->{url}} = $meta{title};
			$photo{$page->{url}} = $content{photo};

		}; 
	
	};

	my $page->{url} = 'allphotos';
	$page->{meta} = {title => 'Фотогалерея', description => 'Фотографии гостиницы'};

	$self->render( 
		layout => $config->{sitename},
		template => $config->{sitename}.'/allphotos',
		album => \%album,
		photo => \%photo,
		page => $page,
	);
};

1;
