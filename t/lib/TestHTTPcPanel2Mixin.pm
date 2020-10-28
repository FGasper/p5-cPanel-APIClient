package TestHTTPcPanel2Mixin;

# Copyright 2020 cPanel, L. L. C.
# All rights reserved.
# http://cpanel.net
#
# This is free software; you can redistribute it and/or modify it under the
# same terms as Perl itself. See L<perlartistic>.

use strict;
use warnings;
use autodie;

use parent (
    'TestHTTPCpanelMixin',
    'Test::Class',
);

use Test::More;
use Test::Deep;
use Test::Fatal;

sub api2_failure : Tests(1) {
    my ($self) = shift;

    my $remote_cp = $self->CREATE(
        service => 'cpanel',

        credentials => {
            username  => 'johnny',
            api_token => 'MYTOKEN',
        },
    );

    my $got = $self->AWAIT( $remote_cp->call_api2( 'Email', 'failberry' ) );

    cmp_deeply(
        $got,
        all(
            methods(
                [ isa => 'cPanel::APIClient::Response::cPanel2' ] => bool(1),
                get_error => re(qr<failberry>),
                get_data  => {
                    content => all(
                        re('cpanel_jsonapi_module=Email'),
                        re('cpanel_jsonapi_func=failberry'),
                        re('cpanel_jsonapi_apiversion=2'),
                        re(qr<&.+&>),
                    ),
                    method  => 'POST',
                    uri     => '/json-api/cpanel',
                    headers => ignore(),
                },
            ),
        ),
        'API response',
    ) or diag explain $got;

    return;
}

sub simple_api2_with_token : Tests(2) {
    my ($self) = shift;

    my $remote_cp = $self->CREATE(
        service => 'cpanel',

        credentials => {
            username  => 'johnny',
            api_token => 'MYTOKEN',
        },
    );

    my $got = $self->AWAIT( $remote_cp->call_api2( 'Email', 'list_forwarders' ) );

    cmp_deeply(
        $got,
        all(
            methods(
                [ isa => 'cPanel::APIClient::Response::cPanel2' ] => bool(1),
                get_error => undef,
                get_data  => {
                    content => all(
                        re('cpanel_jsonapi_module=Email'),
                        re('cpanel_jsonapi_func=list_forwarders'),
                        re('cpanel_jsonapi_apiversion=2'),
                        re(qr<&.+&>),
                    ),
                    method  => 'POST',
                    uri     => '/json-api/cpanel',
                    headers => ignore(),
                },
            ),
        ),
        'API response',
    ) or diag explain $got;

    my %headers = @{ $got->get_data()->{'headers'} };

    cmp_deeply(
        \%headers,
        superhashof(
            {
                'Authorization' => 'cpanel johnny:MYTOKEN',
                'Content-Type'  => 'application/x-www-form-urlencoded',
            }
        ),
        'headers',
    );

    return;
}

1;
