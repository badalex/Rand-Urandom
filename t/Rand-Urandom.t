use strict;
use warnings;

use Test::More tests => 6;
BEGIN { use_ok('Rand::Urandom') };

ok(\&CORE::GLOBAL::rand == \&Rand::Urandom::useUrandom, "rand() overloaded");

ok(rand() <= 1, '<= 1');
ok(rand(255) <= 255, '<= 255');

my $pid = open(my $fh, '-|');
die "failed to fork: $!" if(!defined $pid);

if ($pid) {
	my $got = <$fh>;
	close($fh);

	my $r = rand();
	ok(defined $got, "child returned");
	ok($got ne $r, "child/parent have different rand")
} else {
	print rand();
	exit 0;
}
