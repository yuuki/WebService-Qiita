package Net::Qiita::Client;
use strict;
use warnings;
use utf8;

use base qw(Net::Qiita::Client::Base);

sub new {
    my ($class, $options) = @_;

    my $self = bless $options, $class;
    if (! $options->{token} && $options->{url_name} && $options->{password}) {
        $self->_login($options);
    }
    $self;
}

sub _login {
    my ($self, $args) = @_;
    my $json = post('/auth', {
        url_name => $args->{url_name},
        password => $args->{password},
    });
    $self->token = $json->{token};
}

1;
