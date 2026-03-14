# DESCRIPTION: CSP module for checking and uploading booking calls from api server
# AUTHOR: MAXIM SVIRIDENKO (), sviridenko.maxim@gmail.com
package ApiCalls;

use strict;
use warnings;
use utf8;

use Mojo::UserAgent;
use Mojo::JSON qw(from_json);
use Mojo::Util qw(b64_encode b64_decode);
use DBIx::Custom;
use Data::Dumper;

my $DEBUG = 1;

&recieve_calls;

sub recieve_calls{
	my $ua = Mojo::UserAgent->new;
	my $bearer_auth = "123";

	my $tx = $ua->get('https://www.3bear.ru/booking/api.json',
            {
                'Authorization' => 'Bearer '.$bearer_auth,
				'Accept' => '*/*',
            }
            );

	my @calls =  @{$tx->result->json};
	my @call_data = ();
	foreach my $key (@calls){
		push @call_data, {
			'call_id' => $key->[0], 
			'call_data' => $key->[1],
			'cdate' => $key->[2],
		},
	};

if ($DEBUG) {
	print Dumper \@call_data;
exit;	
	print "Connect to database...";
    my $dbi = DBIx::Custom->connect(
            dsn => 'dbi:SQLite:dbname=../../db/dev.sql',
            option => {sqlite_unicode => 1}
    );

        $dbi->insert(
			\@call_data,

			table => 'test',
		);
};

	return \@call_data;
};
