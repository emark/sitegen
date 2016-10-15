package Sitegen::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';

has 'login' => sub{
	my $self = shift;	
	return $self->session->{auth} ? 1 : $self->redirect_to('/admin/');
};

sub auth {
	my $self = shift;
	my $config = $self->config;
	my $param = $self->req->params->to_hash();
	if($param->{login} && $param->{pass}){ 
		if($param->{login} eq $config->{login} && $param->{pass} eq $config->{pass}){
			$self->session->{auth} = 1;
			$self->redirect_to('/admin/dashboard/');
		}
	}
}

sub logout {
	my $self = shift;
	my $config = $self->config;
	delete $self->session->{auth};

	$self->redirect_to('/admin/');
}

sub dashboard {
	my $self = shift;
	$self->login;

	my $config = $self->config;

	my $urls = $self->app->dbh->select(
		table =>  $config->{prefix}.$config->{site},
		column => 'url',
	)->values;

	$self->render(urls => $urls);
}

sub add(){
    my $self = shift;
	$self->login;

    my $url = $self->param('url');
	my $config = $self->config;


	if($url){
	    $self->app->dbh->insert(
			{url => $url},
	        table => $config->{prefix}.$config->{site},

    	);
	};
	
	mkdir $config->{downloads}.$url;

    $self->render(type => 'text', text => "Page $url success create.");

}

sub delete(){
	my $self = shift;
	$self->login;

	my $url = $self->param('url');	
	my $confirm = $self->param('confirm');
	my $config = $self->config;
	my $text = "Page $url delete success.";
	my $rmdir = 0;
	
	my @files = $config->{downloads}.$url."/*.*";
	unlink glob $config->{downloads}.$url."/".@files if @files;
	$rmdir = rmdir $config->{downloads}.$url;

	if($confirm && $rmdir){
		$self->app->dbh->delete(
			table => $config->{prefix}.$config->{site},
			where => {url => $url},

		);
	}else{
		$text = "Can't remove page $url. Error: $!";

	};
	
	$self->render( type => 'text', text => $text );

}

sub import {
	my $self = shift;
	$self->login;

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
			table => $config->{prefix}.$config->{site},

		);
	};
	
	$self->render(type => 'text', text => "Update success. Processed ".@pages." pages");
}

sub export {
	my $self = shift;
	$self->login;

	my $url = $self->param('url');
	my $config = $self->config;
	my $pages = '';

	if($url eq '---'){
	 	$pages = $self->app->dbh->select(
 			table => $config->{prefix}.$config->{site}
		
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

sub upload {
    my $self = shift;
    $self->login;

    my $config = $self->config;
	my $downloads = $config->{downloads};
    my $source = $self->param('source');
   	#my $data = $source->slurp;
    my $url = $self->param('url');
	$source->move_to($downloads.$url.'/'.$source->{filename});
	#$source->move_to($downloads.$url.'/'.$source->{filename});
	
	
    $self->render(type => 'text', text => "Upload for $url/$source->{filename}");
}

1;
