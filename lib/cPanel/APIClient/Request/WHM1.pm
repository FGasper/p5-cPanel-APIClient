package cPanel::APIClient::Request::WHM1;

# Copyright 2020 cPanel, L. L. C.
# All rights reserved.
# http://cpanel.net
#
# This is free software; you can redistribute it and/or modify it under the
# same terms as Perl itself. See L<perlartistic>.

use strict;
use warnings;

use parent (
    'cPanel::APIClient::Request::HTTPBase',
    'cPanel::APIClient::Request::CLIBase',
);

use cPanel::APIClient::Utils::JSON    ();
use cPanel::APIClient::Response::WHM1 ();

sub _RESPONSE_CLASS { return 'cPanel::APIClient::Response::WHM1' }

sub _parse_new_args {
    my ( $class, $args_ar ) = @_;

    my ( $func, $args_hr, $metaargs_hr ) = @$args_ar;

    return (
        [$func],
        $args_hr,
        $metaargs_hr,
    );
}

sub new {
    my ( $class, $func, $args_hr, $metaargs_hr ) = @_;

    if ($metaargs_hr) {
        my %args_copy = %$args_hr;
        _parse_metaargs( $metaargs_hr, \%args_copy );
        $args_hr = \%args_copy;
    }

    return bless [ $func, $args_hr ], $class;
}

sub get_http_url_path {
    my ($self) = @_;

    return "/json-api/$self->[0]";
}

sub _get_form_hr {
    my ($self) = @_;

    return {
        ( $self->[1] ? %{ $self->[1] } : () ),
        'api.version' => 1,
    };
}

#----------------------------------------------------------------------

sub _get_cli_pieces {
    my ($self) = @_;

    return (
        '/usr/local/cpanel/bin/whmapi1',
        [ $self->[0] ],
        $self->[1],
    );
}

sub _extract_cli_response {
    return $_[1];
}

#----------------------------------------------------------------------

sub _parse_metaargs { die 'Unimplemented' }

1;
