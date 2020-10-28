package cPanel::APIClient::Request::CLIBase;

# Copyright 2020 cPanel, L. L. C.
# All rights reserved.
# http://cpanel.net
#
# This is free software; you can redistribute it and/or modify it under the
# same terms as Perl itself. See L<perlartistic>.

use strict;
use warnings;

use parent 'cPanel::APIClient::Request';

use cPanel::APIClient::Utils::JSON ();

sub get_cli_command {
    my ( $self, $authn ) = @_;

    my ( $program, $pre_form_ar, $form_hr ) = $self->_get_cli_pieces();

    my $username = $authn && $authn->username();

    local ( $@, $! );
    require cPanel::APIClient::Utils::CLIRequest;

    return (
        $program,
        '--output=json',
        ( $username ? "--user=$username" : () ),
        @$pre_form_ar,
        cPanel::APIClient::Utils::CLIRequest::to_args($form_hr),
    );
}

sub parse_cli_response {
    my ( $self, $resp_body ) = @_;

    my $resp_struct = cPanel::APIClient::Utils::JSON::decode($resp_body);

    $resp_struct = $self->_extract_cli_response($resp_struct);

    return $self->_RESPONSE_CLASS()->new($resp_struct);
}

1;
