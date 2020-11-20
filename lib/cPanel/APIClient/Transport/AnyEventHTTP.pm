package cPanel::APIClient::Transport::AnyEventHTTP;

use strict;
use warnings;

=encoding utf-8

=head1 NAME

=head1 SYNOPSIS

    my $cp = cPanel::APIClient->create(
        service => 'cpanel',
        transport => [
            'AnyEventHTTP',
            hostname => 'greathosting.net',

            # For testing only:
            # tls_verification => 'off',
        ],

        credentials => {
            username => 'hugh',
            api_token -> 'MYTOKEN',
        },
    );

=head1 DESCRIPTION

This module allows L<AnyEvent::HTTP> to serve as transport
for asynchronous cPanel API calls.

It implements the same interface as
L<cPanel::APIClient::Transport::MojoUserAgent>, except:

=over

=item * The L<cPanel::APIClient::Pending> object’s promise class
is L<Promise::ES6> rather than L<Mojo::Promise>.

=back

=cut

#----------------------------------------------------------------------

use parent qw(
  cPanel::APIClient::TransportBase::HTTPBase
  cPanel::APIClient::TransportBase::TLSVerificationBase
);

use AnyEvent::HTTP ();
use Promise::ES6   ();

use cPanel::APIClient::Pending ();
use cPanel::APIClient::X ();
use cPanel::APIClient::Utils::HTTPResponse ();

#----------------------------------------------------------------------

sub new {
    my ( $class, $authn, %opts ) = @_;

    my $self = $class->SUPER::new( $authn, %opts );

    if ('on' eq $self->_parse_tls_verification( \%opts )) {
        $self->{'tls_ctx'} = 'high';
    }

    if ( $self->_needs_session() ) {
        $self->{'cookie_jar'} = {};
    }

    return $self;
}

sub _is_internal_error_status {
    my ($status_from_aehttp) = @_;

    return ($status_from_aehttp >= 590 && $status_from_aehttp <= 599);
}

sub _format_headers_from_ae {
    my $headers = shift;

    # AnyEvent::HTTP alters the Location response header
    # so that any relative URI is converted to an absolute
    # URI. Let’s walk such changes back.
    if (my $loc = $headers->{'location'}) {
        $loc =~ s<.+://[^/]+><>;
        $headers->{'location'} = $loc;
    }

    return;
}

sub _request_http {
    my ($self, $method, $url, $headers_ar, $payload) = @_;

    my $cookie_jar = $self->{'cookie_jar'};
    my $tls_ctx = $self->{'tls_ctx'};

    return Promise::ES6->new( sub {
        my ($res, $rej) = @_;

        AnyEvent::HTTP::http_post(
            $url, $payload,
            headers => { map { @$_ } @$headers_ar },
            cookie_jar => $cookie_jar,
            tls_ctx => $tls_ctx,
            sub {
                my ($data, $headers) = @_;

                my $status_code = $headers->{'Status'};

                if (_is_internal_error_status($status_code)) {
                    $rej->( cPanel::APIClient::X->create( 'SubTransport', $headers->{'Reason'}, status => $status_code ) );
                }
                else {

                    _format_headers_from_ae($headers);

                    my $head_str = join(
                        "\x0d\x0a",
                        "HTTP/@{$headers}{'HTTPVersion', 'Status', 'Reason'}",
                        ( map { "$_: $headers->{$_}" } keys %$headers ),
                        q<>,
                    );

                    my $resp_obj = cPanel::APIClient::Utils::HTTPResponse->new(
                        $status_code,
                        $head_str,
                        $data,
                    );

                    $res->($resp_obj);
                }
            },
        );
    } );
}

sub _get_session_promise {
    my ($self, $service_obj) = @_;

    return $self->{'_session_promise'} ||= $self->_needs_session() && do {
        my $authn = $self->{'authn'};

        my ( $method, $url, $payload ) = $authn->get_login_request_pieces();
        substr( $url, 0, 0, $self->_get_url_base($service_obj) );

        $self->_request_http($method, $url, [], $payload)->then(
            sub {
                my ($resp_obj) = @_;

                return $authn->consume_session_response($resp_obj);
            },
        );
    };
}

sub request {
    my ($self, $service_obj, $request_obj) = @_;

    my $get_promise_cr = sub {
        my ( $method, $url, $headers_ar, $payload ) = $self->_assemble_request_pieces( $service_obj, $request_obj );

        my $req_p = $self->_request_http($method, $url, $headers_ar, $payload);

        return $req_p->then(
            sub {
                my ($resp_obj) = @_;

                return $request_obj->parse_http_response( $resp_obj );
            },
        );
    };

    my $promise = $self->_get_session_promise($service_obj);
    $promise &&= $promise->then($get_promise_cr);
    $promise ||= $get_promise_cr->();

    return cPanel::APIClient::Pending->new( $promise );
}

1;
