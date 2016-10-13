package Sitegen::Controller::Generate;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub page {
	my $self = shift;
	my $config = $self->config;
	my $url = $self->param('url');

 	my $page = $self->app->dbh->select(
 			table => $config->{site},
 			columns => ['meta','content'],
 			where => {url => $url},
 	
 	)->fetch_hash || 0;

	if ($page) {
		my %meta = ();
		foreach my $meta (split('%',$page->{meta})){
			my ($key,$value) = split(':',$meta);
			$meta{$key}= $value;

		};

		$page->{meta} = {%meta};

		my %content = ();
		foreach my $content (split('%',$page->{content})){
			my ($key,$value) = split(':',$content);
			$content{$key}= $value;

		};
		$page->{content} = {%content};

	};



	$page = $page ? $page : {url => '404', meta => {template => '404', title => 'Страница не найдена'}, content =>"Страница <b>$url</b> отсутствует на сервере."};

	$self->render(template => $config->{site}.'/'.$page->{meta}{template}, page => $page, layout => $config->{site});
}

1;
