package Net::Qiita::Client;
use strict;
use warnings;
use utf8;

use parent qw(
    Net::Qiita::Client::Users
    Net::Qiita::Client::Tags
    Net::Qiita::Client::Items
);

sub new {
    my ($class, $options) = @_;

    $options ||= {};
    my $self = bless $options, ref($class) || $class;
    if (! $options->{token} && $options->{url_name} && $options->{password}) {
        $self->_login($options);
    }
    $self;
}

sub rate_limit {
    my ($self, $params) = @_;
    $self->get('/rate_limit', $params);
}

sub _login {
    my ($self, $args) = @_;

    my $info = $self->post('/auth', {
        url_name => $args->{url_name},
        password => $args->{password},
    });
    $self->token($info->{token});
}

1;
