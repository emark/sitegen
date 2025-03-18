use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Sitegen');

# 1
$t->post_ok('/admin/' => form => {login => 'gst', pass => 'vhs'})
# 2
	->status_is(302)
# 3
	->header_is(location => '/admin/dashboard/');

# 4
$t->get_ok('/admin/dashboard/')
# 5
	->status_is(200);

# 6
$t->post_ok('/admin/p/add/' => form => {url => 'test'})
# 7
	->status_is(302)
# 8
	->header_is(location => '/admin/dashboard/')
# 9
	->content_like(qr/Error/);

# 10
$t->get_ok('/admin/logout/')
# 11
	->status_is(302);

done_testing();
