package MockCpsrvd::cpanel;

# Copyright 2020 cPanel, L. L. C.
# All rights reserved.
# http://cpanel.net
#
# This is free software; you can redistribute it and/or modify it under the
# same terms as Perl itself. See L<perlartistic>.

use strict;
use warnings;
use autodie;

use parent qw( MockCpsrvd );

use HTTP::Response ();
use JSON           ();

sub _get_response {
    my ( $self, $req ) = @_;

    my $uri = $req->uri()->as_string();

    my %resp;

    if ( $uri =~ m</execute/> ) {
        %resp = $self->_get_uapi_response($req);
    }
    elsif ( $uri =~ m</json-api/cpanel> ) {
        %resp = $self->_get_api2_response($req);
    }
    else {
        return HTTP::Response->new(
            404, 'Not Found',
            [
                'Content-Type' => 'text/plain',
            ],
            "Bad URL: $uri",
        );
    }

    return HTTP::Response->new(
        200, 'OK',
        [
            'Content-Type' => 'application/json',
        ],
        JSON::encode_json( \%resp ),
    );
}

sub _get_uapi_response {
    my ( $self, $req ) = @_;

    my ( $status, %metadata, @errors, @warnings, @messages );

    my $uri = $req->uri()->as_string();

    $status = ( $uri =~ m<fail> ) ? 0 : 1;

    if ( $uri =~ m<errors> ) {
        push @errors, 'err1', 'err2';
    }

    if ( $uri =~ m<warnings> ) {
        push @warnings, 'warn1', 'warn2';
    }

    if ( $uri =~ m<messages> ) {
        push @messages, 'message1', 'message2';
    }

    return (
        status   => $status,
        metadata => \%metadata,
        errors   => \@errors,
        warnings => \@warnings,
        messages => \@messages,
        data     => _faux_data($req),
    );
}

sub _get_api2_response {
    my ( $self, $req ) = @_;

    my ( $status, %metadata, @errors, @warnings, @messages );

    my $uri = $req->uri()->as_string();

    my %cpresult = (
        data => _faux_data($req),
    );

    if ( $req->content() =~ m<fail> ) {
        $cpresult{'error'} = "failed: " . $req->content();
    }

    return (
        cpanelresult => \%cpresult,
    );
}

sub _faux_data {
    my ($req) = @_;

    return {
        method  => $req->method(),
        uri     => $req->uri()->as_string(),
        headers => [ $req->flatten() ],
        content => $req->content(),
    };
}

1;
