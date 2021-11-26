package Sitegen::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';

has 'login' => sub{
	my $self = shift;	
	return $self->session->{auth} ? 1 : $self->redirect_to('/admin/');
};

my $VERSION = '1.03';
my $GIT = 'https://github.com/emark/sitegen';

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

	my $update = (-e -f -r $config->{update}) ? "Running" : "Complete";

	$self->render(
		urls => $urls,
		update => $update,
		version => $VERSION,
		gitrepo => $GIT,
	);
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
	my $check_url = 0;
	my $alert = {
		type => '', 
		text => '',
	};

	if($url){
		$url=~s/[^a-z]+//g;
		my $check_url = $self->app->dbh->select(
			column => ['url'],
	        table => $config->{prefix}.$config->{site},
			where => {'url' => $url},
		)->value;
		if(!$check_url){
			if (mkdir $config->{downloads}.$url){
			    $self->app->dbh->insert(
					{url => $url},
	    		    table => $config->{prefix}.$config->{site},

		    	);

				$alert = {
					type => 'success',
					text => "Page $url was successfully create.\nDirectory for uploading was created"
				};
			}else{
				$alert = {
					type => 'warning',
					text => "\nPage was not created. Error to create uploading directory",
				};
			};
		}else{
			$alert = {
				type => 'warning',
				text => "Page $check_url already exists"
			};
		};
	
	}else{
		$alert = {
			type => 'warning',
			text => "Error! Empty url"
		};

	};
	
    $self->flash(
		alert => $alert,
	);
	$self->redirect_to('/admin/dashboard/');

}

sub delete(){
	my $self = shift;
	$self->login;

	my $url = $self->param('url');	
	my $confirm = $self->param('confirm') || 0;
	my $config = $self->config;
	my $rmdir = 0;
	my @files = glob ($config->{downloads}.$url."/*.*");
	my $static_file = $config->{static}.$url.$config->{static_extension};
	my $alert = {
		type => 'success',
		text => "Page $static_file was deleted"
	};

	if($confirm){
		unlink @files if @files;
		$rmdir = rmdir $config->{downloads}.$url;

		if($rmdir){
			$self->app->dbh->delete(
				table => $config->{prefix}.$config->{site},
				where => {url => $url},
			);
			#Delete static html file
			unlink $static_file;
		}else{
			$alert = {
				type => 'danger',
				text => "Can't remove page $url. Error: $! $config->{downloads}"
			};

		};

	}else{
		$alert = {
			type => 'warning',
			text => 'Please, confirm page deleting'
		};

	};

	$self->flash( 
		alert => $alert
	);
	$self->redirect_to('/admin/dashboard/');
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

		if($page{url}){
			my $check_url = $self->app->dbh->select(
				column => ['url'],
	    	    table => $config->{prefix}.$config->{site},
				where => {'url' => $page{url}},
			)->value;

			if(!$check_url){
			    $self->app->dbh->insert(
					{%page},
	    	    	table => $config->{prefix}.$config->{site},

		    	);
				mkdir $config->{downloads}.$page{url};

			}else{
				$self->app->dbh->update(
					{%page},
					where => {url => $page{url}},
					table => $config->{prefix}.$config->{site},

				);
			};
		};
	};
	
	$self->flash(
		alert => {
			type => 'success',
			text => "Import success. Processed ".@pages." pages"
		}, 
	);

	$self->redirect_to('/admin/dashboard/');
}

sub edit {
	my $self = shift;
	$self->login;

	my $url = $self->param('url');
	my $config = $self->config;
	my $export = $self->param('export');

 	my $page = $self->app->dbh->select(
 		table => $config->{prefix}.$config->{site},
		where => {url => $url}

	 	)->fetch_hash;

	my $path = $config->{downloads}.$url.'/';
	my @files = glob ($path."*.*");
	foreach my $file (@files){
		$file =~s /$path//;
	};

	my $files = \@files;
	
	if($page){
		if($export){
			$self->res->headers->content_disposition('attachment; filename="export.csv"');
			$self->render(
				page => $page, 
				format => 'csv',
				template => 'admin/export',
			);

		}else{
			$self->render(
				page => $page,
				files => $files,
				saved => 0,
				removed => 0,
				template => 'admin/editor' 
			);
		};
	}else{
		$self->render(
			text => "Not found url: $url",
			format => "txt",
		);	
	};
}

sub upload {
    my $self = shift;
    $self->login;

    my $config = $self->config;
	my $downloads = $config->{downloads};
    my $url = $self->param('url');
	my $uploads = $self->param('source');
	my $alert = {
		type => 'success',
		text => 'File(s) sucessfully uploaded',
	}; 

	if ($uploads->filename){
		foreach my $upload (@{$self->req->every_upload('source')}){
			$upload->move_to($downloads.$url.'/'.$upload->filename);

		};
	}else{
		$alert = {
			type => 'warning',
			text => "Empty filename",
		};
	};

    $self->flash(
		alert => $alert
	);
	$self->redirect_to('/admin/dashboard/');

}

sub save {
	my $self = shift;
	$self->login;

	my $url = $self->param('url');
	my $set_url = $self->param('set_url');
	$set_url = $set_url ? $set_url : $url; #Set set_url as url if empty
	my $meta = $self->param('meta');
	my $content = $self->param('content');
	my $file = $self->param('file');
	my $remove = $self->param('remove');
	my $config = $self->config;
	
	if($set_url ne $url){#Rename uploading directory
		rename ($config->{'downloads'}.$url, $config->{'downloads'}.$set_url);		

	};

	my $page = {
		url => $set_url,
		meta => $meta,
		content => $content
	};
	my $result = $self->app->dbh->update(
		$page,
		table => $config->{prefix}.$config->{site},
		where => {url => $url}
	);

	if($remove){
		unlink $config->{'downloads'}.$url."/$file" or warn "Couldn't delete file $file";
		$remove = $file;
	}else{
		$remove = 0;
		
	};

	my $prefix = $config->{downloads}.$url.'/';
	my @files = glob ($prefix."*.*");
	foreach my $file (@files){
		$file =~s /$prefix//;
	};

	my $files = \@files;
	
	$self->render(
		page => $page,
		saved => 1,
		removed => $remove,
		files => $files,
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

	$self->flash(
		alert => {
			type => 'success',
			text => "Set cron schedule."
		}, 
	);

	$self->redirect_to('/admin/dashboard/');
}

1;
