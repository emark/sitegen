package Sitegen::Controller::Booking;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(to_json from_json);
use Mojo::Util qw(secure_compare);
use Data::Dumper;

sub filling_form(){
	my $self = shift;
	my $config = $self->config;

	my $page->{url} = 'book';
    $page->{meta} = {title => 'Бронирование', description => 'Бронирование гостиничных услуг'};

	$self->render(
		layout => $config->{'sitename'},
		template => $config->{'sitename'}.'/booking',
		format => 'html',
		page => $page,
		failed => 0
	);
};

sub checking_data(){
	my $self = shift;
	my $config = $self->config;
	my $hash = $self->req->params->to_hash;
	my $page->{url} = 'book';
    $page->{meta} = {title => 'Бронирование', description => 'Бронирование гостиничных услуг'};

	my $v = $self->validation;

	$v->required('guests_num')->num(1, 120);
	$v->required('from_date')->size(1, undef);
	$v->required('from_time')->num(0, 23);
	$v->required('till_date')->size(1, undef);
	$v->required('till_time')->num(0, 23);
	$v->required('option_of_living');
	$v->required('customer_name')->size(1, 100);
	$v->required('customer_phone')->check('size', (12, 12))->check('like', qr/^\+7/i);
	$v->required('customer_email')->like(qr/^.+\@.+\..+/i) if $self->req->param('guests_num') > 6;
	$v->required('booking_comment')->size(1, undef) if $self->req->param('option_of_living') == 0;
	$v->required('persdata_agreement');
	$v->required('notify_agreement');
	$v->csrf_protect;

	if (!$v->has_error){
		my $bytes = to_json $hash;
		$self->app->dbh->insert(
	    	{
		   		call => $bytes,			
				cdate => \'datetime()',
				read => 0, # Flag for reading api access
				notify => 0, # Flag for notification function
        	},
        	table => $config->{prefix}.$config->{sitename}.'_book',
      	);
			$self->flash(
				output => $hash,
			);
			return $self->redirect_to('/booking/success.html');
	};	

	$self->render(
		layout => $config->{'sitename'},
		template => $config->{'sitename'}.'/book',
		format => 'html',
		page => $page,
		failed => $v->failed
	);
};

sub success{
  	my $self = shift;
	my $config = $self->config;
	my $page->{url} = 'success';
    $page->{meta} = {title => 'Заявка создана', description => 'Успешное оформление заявки на бронирование гостиничных услуг'};

	$self->render(
		layout => $config->{'sitename'},
		template => $config->{'sitename'}.'/booking/success',
		format => 'html',
		page => $page,
	);
};

sub api_get{
    my $self = shift;
    my $config = $self->config;

	my $calls = $self->app->dbh->select(
		table => $config->{prefix}.$config->{sitename}.'_book',
		where => {read => 0}
	)->fetch_all;

	my $bytes = to_json($calls);

	my $auth_header = $self->req->env->{'REDIRECT_HTTP_AUTHORIZATION'};

	if (defined $auth_header && $auth_header =~ /^Bearer\s+(.+)$/){
		my $token = $1;
		if ($token eq $config->{'api_token'}){
			my @call_id;
			foreach my $key( @{$calls} ){
				push (@call_id, $key->[0]);
			};
			$self->app->dbh->update(
				{read => 1},
				table => $config->{prefix}.$config->{sitename}.'_book',
				where => {id => \@call_id}
			);
		
			return $self->render(text => $bytes);
		};
	};

	$self->render(
		text => 'Authorization required!',
		status => 401
	);
};

1;
