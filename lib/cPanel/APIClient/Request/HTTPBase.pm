package cPanel::APIClient::Request::HTTPBase;

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
use cPanel::APIClient::X           ();

sub get_http_method {
    return 'POST';
}

sub get_http_headers {
    return [ 'Content-Type' => 'application/x-www-form-urlencoded' ];
}

sub get_http_payload {
    my ($self) = @_;

    my $formdata = $self->_get_form_hr();

    local ( $@, $! );
    require cPanel::APIClient::Utils::HTTPRequest;
    return cPanel::APIClient::Utils::HTTPRequest::encode_form($formdata);
}

sub parse_http_response {
    my ( $self, $resp_obj, $resp_body ) = @_;

    if ( $resp_obj->code() !~ m<\A2> ) {
        die cPanel::APIClient::X->create( 'HTTP', $resp_obj->as_string() . $/ . $resp_body );
    }

    my $resp_struct = cPanel::APIClient::Utils::JSON::decode($resp_body);

    return $self->_RESPONSE_CLASS()->new(
        $self->_extract_http_response($resp_struct),
    );
}

sub create_transport_error {
    my ( $self, $description, @properties_kv ) = @_;

    die cPanel::APIClient::X->create( 'SubTransport', $description );
}

# default implementation
sub _extract_http_response {
    return $_[1];
}

1;
