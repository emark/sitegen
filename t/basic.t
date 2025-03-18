use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Sitegen');

# 1
$t->post_ok('/admin/' => form => {login => 'test', pass => 'test'})
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
	->header_is(location => '/admin/dashboard/');

# 9
$t->post_ok('/admin/p/delete/' => form => {url => 'test', confirm => 1})
# 10
	->status_is(302)
# 11
	->header_is(location => '/admin/dashboard/');

# 12
$t->get_ok('/admin/logout/')
# 13
	->status_is(302);

done_testing();
