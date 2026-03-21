#!/usr/bin/env perl
# Send notification for new calls 
# MAXIM SVIRIDENKO (), sviridenko.maxim@gmail.com

use strict;
use warnings;
use utf8;
use local::lib;
use DBIx::Custom;
use Mojo::UserAgent;
use Mojo::JSON qw(from_json);
use Data::Dumper;

my $cfile = 'app.conf';
my %config;
print "Loading config...";

open (CONF, "<", $cfile) || die "Can't load config from file: $cfile";
	while(<CONF>){
		chop $_;
		(my $key, my $val) = split('#', $_);
		utf8::decode($val);
		$config{$key} = $val;
	};
	print "ok\n";
close CONF;

&GetCalls;

sub GetCalls{
	print "Connect to database...";
	my $dbi = DBIx::Custom->connect( 
            dsn => $config{dsn}, 
            user => $config{dbuser}, 
            password => $config{dbpassword}, 
            option => {sqlite_unicode => 1} 
    );
	print "ok\nChecking for new calls...";

	my $calls = $dbi->select(
		table => $config{'table'},
		where => { 
			read => 0,
			notify => 0,
		},
	)->fetch_all;

	print "ok\nGet ".@$calls." new calls\n";
	my @call_id = &SendNotification($calls) if @$calls;
	
	if (@call_id){
		print "Update notify flag...";
		$dbi->update(
        	{notify => 1},
            table => $config{'table'},
            where => {id => \@call_id}
        );
		print "ok";
	};
};

sub SendNotification{
	my $calls = $_[0];
	my @call_id;
	my $text = "Здравствуйте,\nполучено ".@$calls." новых бронирований\n";

	foreach my $key (@{$calls}){

		push (@call_id, $key->[0]);
		my $c = from_json($key->[1]);

		$text = $text."\n---\nЗаказчик: $c->{'customer_name'}\nКонтакты: $c->{'customer_phone'}, $c->{'customer_email'}\nКоличество гостей: $c->{'guests_num'}\nКатегория номера: $c->{'option_of_living'}\nЗаезд: $c->{'from_date'} Время: $c->{'from_time'}\tВыезд: $c->{'till_date'} Время: $c->{'till_time'}\nКомментарий: $c->{'booking_comment'}\n";

		if ($c->{'service'}){
			$text = $text."Дополнительные услуги: ";
			if(ref($c->{'service'}) eq 'ARRAY'){
				$text = $text."@{$c->{'service'}}\n";
			}else{
				$text = $text.$c->{'service'}."\n";
			};
		};
	};

	my @api_gate = (
		'https://api-reserve.msndr.net/v1/email/messages',
		'https://app.smsgold.ru/v1/email/messages',
	);

	my $result = '';

	while (<@api_gate>){
		
		my $api = $_;
		if ($result ne 'Created'){

			print "Sending message to $config{'rcpt'}.\nAPI gate: $api\nStatus: ";

			my $ua = Mojo::UserAgent->new;
			my $tx = $ua->post($api,
			{
				'Authorization' => 'Bearer '.$config{'token'},
				'Accept' => '*/*',
			} => json => {
						from_email => $config{'sender'},
						from_name => $config{'sender_name'},
						to => $config{'rcpt'},
						subject => $config{'subject'},
						text => $text,
						}
			)->result;
		
			$result = $tx->message;
			print $result."\n";
		};
	};

	@call_id = () if $result ne 'Created';
	return @call_id;
};
