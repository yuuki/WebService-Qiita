package Net::Qiita::Client::Base;
use strict;
use warnings;
use utf8;

use LWP::UserAgent;
use JSON;
use HTTP::Response;

use Class::Accessor::Lite (
    rw => [qw(
        url_name
        password
        token
    )],
);

use constant ROOT_URL => 'https://qiita.com/';

sub _agent {
    my $self = shift;
    my $options = {
        ssl_opts => { verify_hostname => 0 },
        timeout  => 10,
    };
    $self->{agent} ||= LWP::Agent->new(%$options);
}

sub _get {
    my ($self, $path, $params) = @_;
    $self->_request('get', $path, $params);
}

sub _post {
    my ($self, $path, $params) = @_;
    $self->_request('post', $path, $params);
}

sub _put {
    my ($self, $path, $params) = @_;
    $self->_request('put', $path, $params);
}

sub _delete {
    my ($self, $path, $params) = @_;
    $self->_request('delete', $path, $params);
}

sub _request {
    my ($self, $method, $path, $params) = @_;

    my $url = $SUPER::ROOT_URL . "/api/v1/$path";
    $params->{token} = $self->token if $self->token;
    my $request = HTTP::Request->new($method => $url);
    $request->header('Content-Type' => 'application/json');
    my $response = agent->request($request);
    JSON->decode_json($response);
}

1;
