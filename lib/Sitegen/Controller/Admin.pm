package Sitegen::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';

sub dashboard {
	my $self = shift;
	my $config = $self->config;

	my $dbi = DBIx::Custom->connect(
		dsn => "dbi:mysql:database=$config->{'dbase'}",
		user => $config->{'user'},
		password => $config->{'pass'},
		option => {mysql_enable_utf8 => 1}
	);
	
	my $urls = $dbi->select(
		table => $config->{site},
		column => 'url',
	)->values;

	$self->render(urls => $urls);
}

sub add(){
    my $self = shift;
    my $url = $self->param('url');

    my $config = $self->config;

    my $dbi = DBIx::Custom->connect(
        dsn => "dbi:mysql:database=$config->{'dbase'}",
        user => $config->{'user'},
        password => $config->{'pass'},
        option => {mysql_enable_utf8 => 1}
    );

	if($url){
	    $dbi->insert(
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

    my $dbi = DBIx::Custom->connect(
        dsn => "dbi:mysql:database=$config->{'dbase'}",
        user => $config->{'user'},
        password => $config->{'pass'},
        option => {mysql_enable_utf8 => 1}
    );

	if($confirm){
		$dbi->delete(
			table => $config->{site},
			where => {url => $url},

		);
	};
	
	$self->render(type => 'text', text => "Page $url delete success");

}

sub upload {
	my $self = shift;
	my $source = $self->param('source');
	my $config = $self->config;

	my $dbi = DBIx::Custom->connect(
		dsn => "dbi:mysql:database=$config->{'dbase'}",
		user => $config->{'user'},
		password => $config->{'pass'},
		option => {mysql_enable_utf8 => 1}
	);

	$source = $source->slurp;
	
	my @pages = split(/\n/, $source);
	my $p = 0;
	foreach my $page (@pages){
		my %page = ();
		($page{url},$page{meta},$page{content}) = split(/\t/, $page);

		$dbi->update(
			{%page},
			where => {url => $page{url}},
			table => $config->{site},

		);
		$p++;
	};
	
	$self->render(type => 'text', text => "Update success. Processed $p pages");
}

sub export {
	my $self = shift;
	my $config = $self->config;

	my $dbi = DBIx::Custom->connect(
		dsn => "dbi:mysql:database=$config->{'dbase'}",
		user => $config->{'user'},
		password => $config->{'pass'},
		option => {mysql_enable_utf8 => 1}
	);

 	my $pages = $dbi->select(
 		table => $config->{site},

 	)->fetch_hash_all;


	$self->render(pages => $pages, format => 'txt');
}

1;
