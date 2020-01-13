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
			$self->session->{auth} = 'true';
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

sub view {
	my $self = shift;
	$self->login;

	my $config = $self->config;
	my $url = $self->param('url');

	$self->redirect_to("/$url.html");

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

    $self->render(
		format => 'txt', 
		text => "Page $url was successfull create."
	);

}

sub delete(){
	my $self = shift;
	$self->login;

	my $url = $self->param('url');	
	my $confirm = $self->param('confirm') || 0;
	my $config = $self->config;
	my $text = "Page $url delete success.";
	my $rmdir = 0;
	my @files = glob ($config->{downloads}.$url."/*.*");

	if($confirm){
		unlink @files if @files;
		$rmdir = rmdir $config->{downloads}.$url;

		if($rmdir){
			$self->app->dbh->delete(
				table => $config->{prefix}.$config->{site},
				where => {url => $url},
			);
		}else{
			$text = "Can't remove page $url. Error: $!"."$config->{downloads}";
	
		};

	}else{
		$text = 'Please, confirm page deleting';

	};

	$self->render( 
		format => 'txt', 
		text => $text 
	);

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
	
	$self->render(
		text => "Import success. Processed ".@pages." pages", 
		format => "txt");
}

sub export {
	my $self = shift;
	$self->login;

	my $url = $self->param('url');
	my $config = $self->config;
	my $editor = $self->param('editor');
	my $page = '';

 	$page = $self->app->dbh->select(
 		table => $config->{prefix}.$config->{site},
		where => {url => $url}

	 	);

	$page = $page->fetch_hash;
	
	if($editor){
		$self->render(
			page => $page, 
			saved => 0,
			template => 'admin/editor' 
		);
	}else{
		$self->render(
			page => $page, 
			format => 'txt'
		);

	};
}

sub upload {
    my $self = shift;
    $self->login;

    my $config = $self->config;
	my $downloads = $config->{downloads};
    my $source = $self->param('source');
    my $url = $self->param('url');
	my $filename = $config->{site}.'-'.$url.'-'.$source->{filename};
	my $text = "Upload for $downloads$url/$filename"; 
	
	if ($source->{filename}){
		$source->move_to($downloads.$url.'/'.$filename);

	}else{
		$text = "Empty filename";
	};

    $self->render(
		format => 'txt', 
		text => $text
	);
}

sub edit {
	my $self = shift;
	$self->login;

	my $url = $self->param('url');
	my $meta = $self->param('meta');
	my $content = $self->param('content');
	my $config = $self->config;
	my $page = {
		url => $url,
		meta => $meta,
		content => $content
	};
	my $result = $self->app->dbh->update(
		$page,
		table => $config->{prefix}.$config->{site},
		where => {url => $url}
	);


	$self->render(
		page => $page,
		saved => 1,
		template => 'admin/editor'
	);
}

sub update {
	my $self = shift;
	$self->login;

	my $config = $self->config;
	my @urls = $self->app->dbh->select(
		table =>  $config->{prefix}.$config->{site},
		column => ['url'],
	)->flat;
	
	open (CRON, "> $config->{update}") || die "Can't open file: $config->{update}";
	foreach my $url (@urls){
		print CRON "http://www.".$config->{site}.".ru/".$url.".html\n";
	};
	close (CRON);

	$self->render(
		text => "Set cron schedule.", 
		format => "txt"
	);
}

1;
