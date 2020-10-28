package cPanel::APIClient::Service::cpanel;

use strict;
use warnings;

=encoding utf-8

=head1 NAME

cPanel::APIClient::Service::cpanel

=head1 SYNOPSIS

If your transport uses blocking I/O:

    my $resp = $client->call_uapi('Email', 'list_pops', \%args);

    my $pops_ar = $resp->get_data();

If your transport uses non-blocking I/O:

    my $call = $client->call_uapi('Email', 'list_pops', \%args);

    $call->promise()->then( sub {
        my ($resp) = @_;

        my $pops_ar = $resp->get_data();
    } );

Some non-blocking transports support canceling in-progress requests, thus:

    $client->cancel($call, ..);

See your transport’s documentation for more details.

=cut

#----------------------------------------------------------------------

use parent qw( cPanel::APIClient::Service );

# overridden in tests
our $_PORT = 2083;

#----------------------------------------------------------------------

=head1 METHODS

=head2 $whatsit = I<OBJ>->call_uapi( $MODULE, $FUNC, \%ARGS, \%METAARGS )

Calls a single UAPI call. %ARGS values should be simple scalars or arrays
thereof.

Check L<cPanel’s documentation|https://documentation.cpanel.net/display/DD/Guide+to+UAPI> for descriptions of each available UAPI call.

The return value depends on I<OBJ>’s configured transport:

=over

=item * If the transport uses blocking I/O, then the return will be a
L<cPanel::APIClient::Response::UAPI> instance.

=item * A transport that uses non-blocking I/O can determine its own
mechanism
for returning the API call response. Some might return a promise (e.g.,
L<Promise::XS>), others a L<Future>, and still others might
return nothing and instead take a callback as a parameter. See the
individual transport’s documentation for details. Eventually, though,
a L<cPanel::APIClient::Response::UAPI> instance should somehow be given
to indicate the API call response.

=back

=cut

sub call_uapi {
    my ( $self, $module, $func, $args_hr, $metaargs_hr ) = @_;

    require cPanel::APIClient::Request::UAPI;
    return $self->_call(
        'cPanel::APIClient::Request::UAPI',
        [ $module, $func, $args_hr, $metaargs_hr ],
    );
}

#----------------------------------------------------------------------

=head2 $whatsit = I<OBJ>->call_api2( $MODULE, $FUNC, \%ARGS, \%METAARGS )

Like C<call_uapi()> but calls API 2 instead of UAPI. The eventual response
is a L<cPanel::APIClient::Response::cPanel2> instance.

Check L<cPanel’s documentation|https://documentation.cpanel.net/display/DD/Guide+to+cPanel+API+2> for descriptions of each available API 2 call.

B<NOTE:> cPanel’s API 2 is deprecated. Some API 2 functionality is
also available via UAPI. For such cases, prefer UAPI.

=cut

sub call_api2 {
    my ( $self, $module, $func, $args_hr, $metaargs_hr ) = @_;

    require cPanel::APIClient::Request::cPanel2;
    return $self->_call(
        'cPanel::APIClient::Request::cPanel2',
        [ $module, $func, $args_hr, $metaargs_hr ],
    );
}

#----------------------------------------------------------------------

# undocumented for now
sub get_https_port {
    return $_PORT;
}

#----------------------------------------------------------------------

sub _call {
    my ( $self, $reqclass, $reqargs_ar ) = @_;

    my $metaargs_hr = $reqargs_ar->[-1];

    die "Meta-arguments are not implemented!" if $metaargs_hr;

    my $req = $reqclass->new(@$reqargs_ar);

    return $self->{'transporter'}->request( $self, $req );
}

=head1 LICENSE

Copyright 2020 cPanel, L. L. C. All rights reserved. L<http://cpanel.net>

This is free software; you can redistribute it and/or modify it under the
same terms as Perl itself. See L<perlartistic>.

=cut

1;
