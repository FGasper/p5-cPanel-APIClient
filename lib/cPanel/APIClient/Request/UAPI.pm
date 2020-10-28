package cPanel::APIClient::Request::UAPI;

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
    'cPanel::APIClient::Request::ModularBase',
);

use cPanel::APIClient::Utils::JSON    ();
use cPanel::APIClient::Response::UAPI ();

sub _RESPONSE_CLASS { return 'cPanel::APIClient::Response::UAPI' }

sub get_http_url_path {
    my ($self) = @_;

    return "/execute/$self->[0]/$self->[1]";
}

sub _get_form_hr {
    my ($self) = @_;

    return $self->[2];
}

#----------------------------------------------------------------------

sub _get_cli_pieces {
    my ($self) = @_;

    return (
        '/usr/local/cpanel/bin/uapi',
        [ @{$self}[ 0, 1 ] ],
        $self->[2],
    );
}

sub _extract_cli_response {
    my ( $self, $resp_struct ) = @_;

    return $resp_struct->{'result'};
}

#----------------------------------------------------------------------

sub _parse_metaargs { die 'Unimplemented' }

1;
