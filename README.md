# NAME

Rand::Urandom - replaces rand() with /dev/urandom

# SYNOPSIS

    use Rand::Urandom();

# DESCRIPTION

http://sockpuppet.org/blog/2014/02/25/safely-generate-random-numbers/

Perl's built-in rand has a few problems:

- the state is inherited across fork(), meaning its real easy to generate/use the
same "random" number twice. Especially when using mod\_perl. Yes I've been
bitten by this before.
- per perldoc "rand()" is not cryptographically secure. You should not rely on it in security-sensitive situations."
- seeding is hard to get right

By default it uses the getentropy() (only available in > Linux 3.17) and falls
back to /dev/arandom and then /dev/urandom. Otherwise it dies.

This means it should "DoTheRightThing" on most unix based systems, including,
OpenBSD, FreesBSD, Mac OSX, Linux, blah blah.

## EXPORT

None by default.

# SEE ALSO

https://github.com/badalex/Rand-Urandom

# AUTHOR

Alex Hunsaker, <badalex@gmail.com<gt>

# COPYRIGHT AND LICENSE

Copyright (C) 2014 by Alex Hunsaker

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.20.1 or,
at your option, any later version of Perl 5 you may have available.
