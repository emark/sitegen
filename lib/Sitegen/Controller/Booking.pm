package Sitegen::Controller::Booking;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(decode_json encode_json);

my %page = (url => 'booking');

sub complete {
	my $self = shift;
	my $config = $self->config;
	my $params = $self->req->params->to_hash;
	my @dict = qw(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9);
	my $token = '';
	my $msg = '';

	if(!$params->{token}){
		#Generate token
		for(my $i=0; $i<30; $i++){
			my $rnd = 0;
			while ($rnd <= 62)
			{
				 $rnd = int(rand(1000));
			};
			$token = $token.$dict[int(rand(62))];
	
		}
	
		my $content = encode_json $params;	
		$self->app->dbh->insert(
			{
				content => $content,
				token => $token
			},
			ctime => 'ctime',
			table => $config->{prefix}.'booking'		

		);
		$page{token} = $token;
		$msg = 'Ваш запрос на бронирование успешно создан.';

	}else{
		my $content = $self->app->dbh->select(
						table => $config->{prefix}.'booking',
						columns => ['content'],
						where => {token => $params->{token}},
						)->fetch_hash;

		utf8::encode($content->{content});

		my $bytes = decode_json $content->{content};

		foreach my $key (keys %{$params}){
			$bytes->{$key} = $params->{$key};
	
		};
		delete $bytes->{token};

		$content = encode_json $bytes;
		$self->app->dbh->update(
			{content => $content},
			table => $config->{prefix}.'booking',
			where => {token => $params->{token}},

		);
		$page{token} = '';
		$msg = 'Благодарим за выбор нашей гостиницы!';

	};
	$page{msg} = $msg;

	$self->render(
		template => $config->{site}.'/booking/complete', 
		layout => $config->{site},
		page => \%page,

	);
};

sub add {
	my $self = shift;
	my $config = $self->config;

	$self->render(
		template => $config->{site}.'/booking/booking', 
		layout => $config->{site},
		page => \%page
	);

};

1;
