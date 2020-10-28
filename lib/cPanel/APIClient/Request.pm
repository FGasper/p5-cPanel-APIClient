package cPanel::APIClient::Request;

# Copyright 2020 cPanel, L. L. C.
# All rights reserved.
# http://cpanel.net
#
# This is free software; you can redistribute it and/or modify it under the
# same terms as Perl itself. See L<perlartistic>.

use strict;
use warnings;

sub new {
    my ( $class, @args ) = @_;

    my ( $ref_ar, $args_hr, $metaargs_hr ) = $class->_parse_new_args( \@args );

    if ($metaargs_hr) {
        my %args_copy = %$args_hr;
        $class->_parse_metaargs( $metaargs_hr, \%args_copy );
        $args_hr = \%args_copy;
    }

    push @$ref_ar, $args_hr;

    return bless $ref_ar, $class;
}

1;
