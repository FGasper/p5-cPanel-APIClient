package cPanel::APIClient::Response::cPanel2;

use strict;
use warnings;

=encoding utf-8

=head1 NAME

cPanel::APIClient::Response::cPanel2

=head1 DESCRIPTION

This class represents a response to a cPanel API 2 call.

=cut

#----------------------------------------------------------------------

use parent qw( cPanel::APIClient::Response );

#----------------------------------------------------------------------

=head1 METHODS

=head2 $scalar = I<OBJ>->get_error()

Returns an error message, or undef if the API call succeeded.

=cut

sub get_error {
    return $_[0]{'error'};
}

#----------------------------------------------------------------------

=head2 $thing = I<OBJ>->get_data()

Returns the API payload.

=cut

sub get_data {
    return $_[0]{'data'};
}

#----------------------------------------------------------------------

=head1 LICENSE

Copyright 2020 cPanel, L. L. C. All rights reserved. L<http://cpanel.net>

This is free software; you can redistribute it and/or modify it under the
same terms as Perl itself. See L<perlartistic>.

=cut

1;
