#!/usr/bin/env perl

# Copyright 2020 cPanel, L. L. C.
# All rights reserved.
# http://cpanel.net
#
# This is free software; you can redistribute it and/or modify it under the
# same terms as Perl itself. See L<perlartistic>.

package t::anyeventhttp;

use strict;
use warnings;
use autodie;

use FindBin;
use lib "$FindBin::Bin/lib";

use parent (
    'TestHTTPBase',
    'TestHTTPUAPIMixin',
    'TestHTTPWHM1Mixin',
);

use Test::More;

use Test::FailWarnings;

__PACKAGE__->new()->runtests() if !caller;

use constant _CP_REQUIRE => (
    'AnyEvent',
    'AnyEvent::HTTP',
    sub { diag "Using AnyEvent $AnyEvent::VERSION"; },
    sub { diag "Using AnyEvent::HTTP $AnyEvent::HTTP::VERSION"; },
);

sub TRANSPORT_PIECE {
    return ('AnyEventHTTP');
}

sub AWAIT {
    my ( $self, $pending ) = @_;

    my $cv = AnyEvent->condvar();

    $pending->promise()->then(
        $cv,
        sub { $cv->croak(shift) },
    );

    return $cv->recv();
}

1;
