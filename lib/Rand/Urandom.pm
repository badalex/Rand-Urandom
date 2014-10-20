package Rand::Urandom;
use strict;
use warnings;
use Config;
use POSIX qw(EINTR ENOSYS);

our $VERSION = '0.01';

sub useUrandom(;$) {
	my $max = shift || 1;

	my $buf = trySyscall();
	if (!$buf) {
		my $file = -r '/dev/arandom' ? '/dev/arandom' : '/dev/urandom';
		open(my $fh, '<:raw', $file) || die "Rand::Urandom: Can't open $file: $!";

		my $got = read($fh, $buf, 8);
		if ($got == 0 || $got != 8) {
			die "Rand::Urandom: failed to read from $file: $!";
		}
		close($fh);
	}

	my $n = unpack('Q', $buf);
	return $n if($max == -1);

	$max *= $n / 2**64;
	return $max;
}

sub trySyscall {
	if ($Config{'osname'} !~ m/linux/) {
		return;
	}

	my $num = $Config{'archname'} =~ m/x86_64/ ? 318 : 355;
	my $ret;
	my $buf   = ' ' x 8;
	my $tries = 0;
	do {
		$ret = syscall($num, $buf, 8, 0);
		if ($! == ENOSYS) {
			return;
		}

		if ($ret != 8) {
			warn "Rand::Urandom: huh, getrandom() returned $ret... trying again";
			$ret = -1;
			$!   = EINTR;
		}

		if ($tries++ > 100) {
			warn "Rand::Urandom: getrandom() looped lots, falling back";
			return;
		}
	} while ($ret == -1 && $! == EINTR);

	return $buf;
}

our $OrigRand;
sub BEGIN {
	no warnings 'redefine';
	$OrigRand           = \&CORE::rand;
	*CORE::GLOBAL::rand = \&useUrandom;
}


1;
__END__

=head1 NAME

Rand::Urandom - replaces rand() with /dev/urandom

=head1 SYNOPSIS

  use Rand::Urandom();

=head1 DESCRIPTION

http://sockpuppet.org/blog/2014/02/25/safely-generate-random-numbers/

Perl's built-in rand has a few problems:

=over

=item *
the state is inherited across fork(), meaning its real easy to generate/use the
same "random" number twice. Especially when using mod_perl. Yes I've been
bitten by this before.

=item *
per perldoc "rand()" is not cryptographically secure. You should not rely on it in security-sensitive situations."

=item *
seeding is hard to get right

=back

By default it uses the getentropy() (only available in > Linux 3.17) and falls
back to /dev/urandom. Otherwise it dies.

This means it should "DoTheRightThing" on most unix based systems, including,
OpenBSD, FreesBSD, Mac OSX, Linux, blah blah.


=head2 EXPORT

None by default.



=head1 SEE ALSO

https://github.com/badalex/Rand-Urandom

=head1 AUTHOR

Alex Hunsaker, E<lt>badalex@gmail.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Alex Hunsaker

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.20.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
