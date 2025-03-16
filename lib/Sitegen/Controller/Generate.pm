package Sitegen::Controller::Generate;
use Mojo::Base 'Mojolicious::Controller';

sub sitemap {
	my $self = shift;
	my $config = $self->config;
	my $urls = $self->app->dbh->select(
		column => ['url'],
		table => $config->{prefix}.$config->{sitename}
	)->fetch_all;

	my @lastmod = localtime;
	$lastmod[3] = '0'.$lastmod[3] if($lastmod[3] < 10);
	$lastmod[4] = $lastmod[4]+1;
	$lastmod[4] = '0'.$lastmod[4] if($lastmod[4] < 10);
	$lastmod[5] = $lastmod[5]+1900;
	$lastmod[0] = "$lastmod[5]-$lastmod[4]-$lastmod[3]";

	$self->render(
		template => 'sitemap',
		format => 'xml',
		urls => $urls,
		site => $config->{sitename},
		lastmod => $lastmod[0]
	);

}

sub page {
	my $self = shift;
	my $config = $self->config;
	my $url = $self->param('url');

 	my $page = $self->app->dbh->select(
 			table =>$config->{prefix}.$config->{sitename},
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

		if($page->{meta}{template} ne 'script'){
			my %content = ();
			foreach my $content (split('%',$page->{content})){
				my ($key,$value) = split(':',$content);
				$content{$key}= $value;

			};

			$page->{content} = {%content};
		};
	
		$page->{status} = '200';

	};

	$page = $page ? $page : {url => '404', status => 404, meta => { template => '404', title => 'Страница не найдена' }, content => "Страница <b>$url</b> отсутствует на сервере." };

	$self->render( 
		layout => $config->{sitename},
		template => $config->{sitename}.'/'.$page->{meta}{template},
		format => 'html',
		status => $page->{status},
		page => $page,
		site => $config->{sitename}
	);
}

1;
