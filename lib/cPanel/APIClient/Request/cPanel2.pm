package cPanel::APIClient::Request::cPanel2;

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

use cPanel::APIClient::Utils::JSON       ();
use cPanel::APIClient::Response::cPanel2 ();

sub _RESPONSE_CLASS { return 'cPanel::APIClient::Response::cPanel2' }

sub get_http_url_path {
    my ($self) = @_;

    return "/json-api/cpanel";
}

sub _get_form_hr {
    my ($self) = @_;

    my %formdata = (
        ( $self->[2] ? %{ $self->[2] } : () ),

        cpanel_jsonapi_apiversion => 2,
        cpanel_jsonapi_module     => $self->[0],
        cpanel_jsonapi_func       => $self->[1],
    );

    return \%formdata;
}

sub _extract_http_response {
    my ( $self, $resp_struct ) = @_;

    return $resp_struct->{'cpanelresult'} || do {
        require Data::Dumper;
        die "Malformed response (lacks “cpanelresult”): " . Data::Dumper::Dumper($resp_struct);
    };
}

#----------------------------------------------------------------------

sub _get_cli_pieces {
    my ($self) = @_;

    return (
        '/usr/local/cpanel/bin/cpapi2',
        [ @{$self}[ 0, 1 ] ],
        $self->[2],
    );
}

*_extract_cli_response = *_extract_http_response;

#----------------------------------------------------------------------

sub _parse_metaargs { die 'Unimplemented' }

1;
