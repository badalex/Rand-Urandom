use strict;
use warnings;

use Test::More tests => 9;
BEGIN { use_ok('Rand::Urandom', qw(perl_rand rand_bytes)) };

ok(\&CORE::GLOBAL::rand == \&Rand::Urandom::use_urandom, "rand() overloaded");

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

ok(defined perl_rand(), "perl_rand");
ok(length(rand_bytes(8)) == 8, "rand_bytes");
ok(rand(2**64), "rand uint64");
