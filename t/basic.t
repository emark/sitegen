use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Sitegen');
#Testing admin page
$t->post_ok('/admin/')->status_is(200);

done_testing();
