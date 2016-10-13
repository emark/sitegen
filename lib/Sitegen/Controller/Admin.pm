package Sitegen::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';

sub dashboard {
	my $self = shift;
	my $config = $self->config;
	my $urls = $self->app->dbh->select(
		table => $config->{site},
		column => 'url',
	)->values;

	$self->render(urls => $urls);
}

sub add(){
    my $self = shift;
    my $url = $self->param('url');
	my $config = $self->config;

	if($url){
	    $self->app->dbh->insert(
			{url => $url},
	        table => $config->{site},

    	);
	};

    $self->render(type => 'text', text => "Page $url success create");

}

sub delete(){
	my $self = shift;
	my $url = $self->param('url');	
	my $confirm = $self->param('confirm');
	my $config = $self->config;

	if($confirm){
		$self->app->dbh->delete(
			table => $config->{site},
			where => {url => $url},

		);
	};
	
	$self->render(type => 'text', text => "Page $url delete success");

}

sub upload {
	my $self = shift;
	my $source = $self->param('source');
	$source = $source->slurp;
	my $config = $self->config;
	my @pages = split(/\n/, $source);

	foreach my $page (@pages){
		my %page = ();
		($page{url},$page{meta},$page{content}) = split(/\t/, $page);

		$self->app->dbh->update(
			{%page},
			where => {url => $page{url}},
			table => $config->{site},

		);
	};
	
	$self->render(type => 'text', text => "Update success. Processed ".@pages." pages");
}

sub export {
	my $self = shift;
	my $url = $self->param('url');
	my $config = $self->config;
	my $pages = '';

	if($url eq '---'){
	 	$pages = $self->app->dbh->select(
 			table => $config->{site}
		
	 	);
	}else{
	 	$pages = $self->app->dbh->select(
 		table => $config->{site},
		where => {url => $url}

	 	);
	};

	$pages = $pages->fetch_hash_all;

	$self->render(pages => $pages, format => 'txt');
}

1;
