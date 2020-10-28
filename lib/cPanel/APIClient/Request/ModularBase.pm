package cPanel::APIClient::Request::ModularBase;

# Copyright 2020 cPanel, L. L. C.
# All rights reserved.
# http://cpanel.net
#
# This is free software; you can redistribute it and/or modify it under the
# same terms as Perl itself. See L<perlartistic>.

use strict;
use warnings;

sub _parse_new_args {
    my ( $class, $args_ar ) = @_;

    my ( $module, $func, $args_hr, $metaargs_hr ) = @$args_ar;

    return (
        [ $module, $func ],
        $args_hr,
        $metaargs_hr,
    );
}

1;
