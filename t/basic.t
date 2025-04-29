use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Sitegen');

# 1
$t->post_ok('/admin/' => form => {login => 'dev', pass => 'dev'})
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

# 14
$t->get_ok('/allphotos.html')
# 15
	->status_is(200);

# 16
$t->get_ok('/rentals/0-0.html')
# 17
	->status_is(200);

done_testing();
